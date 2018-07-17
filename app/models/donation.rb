require 'csv'

class Donation < ActiveRecord::Base
  include Mailchimpable
  include TagAnActivistOmatic

  store_accessor :customer

  belongs_to :widget
  belongs_to :activist
  belongs_to :subscription_relation, foreign_key: :local_subscription_id, class_name: 'Subscription'

  has_one :mobilization, through: :widget
  has_one :community, through: :mobilization

  belongs_to :parent, class_name: 'Donation'
  belongs_to :payable_transfer

  has_many :payments
  has_many :payable_details
  has_many :transitions, class_name: "DonationTransition", autosave: false

  after_create :send_mail, unless: :skip?
  after_create :async_update_mailchimp
  after_commit :add_automatic_tags, on: :create

  delegate :name, to: :mobilization, prefix: true

  default_scope { joins(:mobilization) }

  scope :by_widget, -> (widget_id) { where(widget_id: widget_id) if widget_id }
  scope :by_community, -> (community_id) { where("community_id = ?", community_id) if community_id }
  scope :paid, -> { where(transaction_status: 'paid') }

  scope :ordered, -> { order(id: :desc) }

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
           to: :state_machine

  def state_machine
    @state_machine ||= DonationMachine.new(
      self,
      transition_class: DonationTransition,
      association_name: :transitions)
  end

  def boleto?
    self.payment_method == 'boleto'
  end

  def subscription?
    self.subscription || subscription_relation.present?
  end


  def process_card_hash?
    !self.subscription? or (self.subscription? and self.subscription_donations?)
  end

  def subscription_donations?
    if self.subscription? and self.subscription_relation.try(:donations).present?
      return true if self.subscription_relation.try(:donations).try(:count) < 0
    else
      false
    end
  end

  def self.to_txt
    attributes = %w{
    id email amount_formatted payment_method mobilization_name widget_id
    created_at donor transaction_id transaction_status subscription_id
    }

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |donation|
        csv << attributes.map{ |a| donation.send(a) }
      end
    end
  end

  def donor
    self.activist.name if self.activist
  end

  def amount_formatted
    self.amount / 100
  end

  def send_mail
    begin
      if self.local_subscription_id.nil? || (self.subscription_relation.donations.size == 1)
        DonationsMailer.thank_you_email(self).deliver_later!
      end
    rescue StandardError => e
      Raven.capture_exception(e) unless Rails.env.test?
      logger.error("\n==> ERROR SENDING DONATION EMAIL: #{e.inspect}\n")
    end
  end

  def pagarme_transaction
    @pagarme_transaction ||= PagarMe::Transaction.find_by_id transaction_id
  end

  def update_pagarme_data
    update_attributes(
      gateway_data: pagarme_transaction.to_json,
      payables: pagarme_transaction.try(:payables))
    transition_to(pagarme_transaction.status.to_sym, pagarme_transaction.to_json)
  end

  def async_update_mailchimp
    MailchimpSyncWorker.perform_async(self.id, 'donation')
  end

  def update_mailchimp
    subscribe_to_list(self.activist.email, subscribe_attributes)
    subscribe_to_segment(self.widget.mailchimp_segment_id, self.activist.email)
    if self.current_state.to_sym == :paid
      widget.create_mailchimp_donators_segments
      subscribe_to_segment(self.widget.mailchimp_unique_segment_id, self.activist.email) 
    end
    update_member(self.activist.email, { groupings: groupings }) if groupings
  end

  def generate_activist
    if activistable?
      activist_email = self.customer['email']
      activist_found = Activist.by_email activist_email
      if activist_found
        self.activist = activist_found 
      else
        activist_name = self.customer['name']
        doc_number = self.customer['document_number']
        self.create_activist name: activist_name, email: activist_email, phone: self.customer['phone'], document_number: doc_number, 
          document_type: doc_type(doc_number), city: self.customer['city']
      end
      self.save
    end
  end

  def reload_transaction_data
    trans = DonationService.load_transaction self.transaction_id
    if trans
      obj = fill_customer trans
      self.email = obj['email'] if  (! self.try :email) && (obj['email'])
      self.customer = obj if obj.size > 0
    end
  end

  def notify_when_not_subscription template_name
    unless subscription?
      notify_activist(template_name.to_sym)
    end
  end

  private

  def fill_customer trans
    obj = { }
    address = trans['address'].to_json only: ['zipcode', 'street', 'street_number', 'complementary', 'neighborhood', 'city', 'state']
    phone = (trans['phone'].to_json only: ['ddd', 'number'])

    obj['address'] = address if not_empty_val(address)
    obj['phone'] = phone if not_empty_val(phone)

    if trans['customer']
      fill_customer_in_transaction trans, obj
    else
      fill_no_customer_in_transaction trans, obj
    end
    return obj
  end

  def not_empty_val var
    var and var != '{}' and var != 'null'
  end

  def fill_customer_in_transaction trans, customer_obj
    customer_obj['name'] = trans['customer']['name'] if trans['customer']['name'] 
    customer_obj['email'] = trans['customer']['email'] if trans['customer']['email'] 
    customer_obj['document_number'] = trans['customer']['document_number'] if trans['customer']['document_number'] 
    customer_obj['document_type'] = trans['customer']['document_type'] if trans['customer']['doc_type'] 
  end

  def fill_no_customer_in_transaction trans, customer_obj
    if trans.try(:card)
      customer_obj['name'] = trans.card.holder_name  if trans.card.holder_name
    end
    if trans.try(:metadata)
      customer_obj['email'] = trans.metadata.email if trans.metadata.email
    end
  end

  def activistable?
    cus = try(:customer) || { } 
    return ( cus['name'] && cus['email'] )
  end

  def doc_type doc
    case doc.size
    when 11
      return 'cpf'
    when 14
      return 'cnpj'
    else 
      return nil
    end
  end

  def subscribe_attributes
    return_attributes = {
      FNAME: self.activist.first_name,
      LNAME: self.activist.last_name,
      EMAIL: self.activist.email,
    }
    return_attributes[:CITY] = self.activist.city if self.activist and self.activist.city
    return_attributes
  end

  def notify_activist(template_name, template_vars = {}, auto_deliver = true)
    Notification.notify!(
      activist_id,
      template_name,
      default_template_vars.merge(template_vars),
      community.id,
      auto_deliver)
  end

  def default_template_vars
    global = {
      payment_method: payment_method,
      widget_id: widget_id,
      mobilization_id: mobilization.try(:id),
      mobilization_name: mobilization.try(:name),
      boleto_expiration_date: gateway_data.try(:[], 'boleto_expiration_date'),
      boleto_barcode: gateway_data.try(:[], 'boleto_barcode'),
      boleto_url: gateway_data.try(:[], 'boleto_url'),
      card_last_digits: gateway_data.try(:[], 'card_last_digits'),
      created: created_at.strftime("%d/%m/%Y"),
      donation_id: id,
      activist_id: activist_id,
      amount: ( amount / 100),
      customer_document: (gateway_data['customer']['document_number']).gsub(/\A(\d{3})(\d{3})(\d{3})(\d{2})\Z/, "\\1.\\2.\\3-\\4"),
      community: {
        id: community.id,
        name: community.name,
        image: community.image
      },
      customer: {
        name: activist.name,
        first_name: activist.name.split(' ').try(:first),
        document_number: activist.try(:document_number)
      }
    }
  end

end
