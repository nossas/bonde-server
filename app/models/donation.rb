require 'csv'

class Donation < ActiveRecord::Base
  include Mailchimpable

  store_accessor :customer

  belongs_to :widget
  belongs_to :activist

  has_one :mobilization, through: :widget
  has_one :community, through: :mobilization

  belongs_to :parent, class_name: 'Donation'
  belongs_to :payable_transfer

  has_many :payments
  has_many :payable_details

  after_create :send_mail, unless: :skip?
  after_create :async_update_mailchimp

  delegate :name, to: :mobilization, prefix: true

  default_scope { joins(:mobilization) }

  scope :by_widget, -> (widget_id) { where(widget_id: widget_id) if widget_id }
  scope :by_community, -> (community_id) { where("community_id = ?", community_id) if community_id }

  def boleto?
    self.payment_method == 'boleto'
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
      DonationsMailer.thank_you_email(self).deliver_later!
    rescue StandardError => e
      Raven.capture_exception(e) unless Rails.env.test?
      logger.error("\n==> ERROR SENDING DONATION EMAIL: #{e.inspect}\n")
    end
  end

  def pagarme_transaction
    @pagarme_transaction ||= PagarMe::Transaction.find_by_id transaction_id
  end

  def update_pagarme_data
    self.update_attributes(
      transaction_status: pagarme_transaction.status,
      gateway_data: pagarme_transaction.to_json,
      payables: pagarme_transaction.try(:payables)
    )
  end

  def async_update_mailchimp
    Resque.enqueue(MailchimpSync, self.id, 'donation')
  end

  def update_mailchimp
    subscribe_to_list(self.activist.email, subscribe_attributes)
    subscribe_to_segment(self.widget.mailchimp_segment_id, self.activist.email)
    update_member(self.activist.email, { groupings: groupings })
  end

  private

  def subscribe_attributes
    return_attributes = {
      FNAME: self.activist.first_name,
      LNAME: self.activist.last_name,
      EMAIL: self.activist.email,
    }
    return_attributes[:CITY] = self.activist.city if self.activist and self.activist.city
    return_attributes
  end
end
