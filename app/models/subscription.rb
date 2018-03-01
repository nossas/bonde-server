class Subscription < ActiveRecord::Base
  include Mailchimpable

  belongs_to :widget
  belongs_to :activist
  belongs_to :community

  has_many :donations, foreign_key: :local_subscription_id
  has_many :transitions, class_name: "SubscriptionTransition", autosave: false

  validates :widget, :activist, :community, :amount, presence: true

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
           to: :state_machine

  def state_machine
    @state_machine ||= SubscriptionMachine.new(
      self,
      transition_class: SubscriptionTransition,
      association_name: :transitions)
  end

  def reached_retry_limit?
    last_transition_created = last_transition.try(:created_at) || DateTime.now
    current_state == 'unpaid' && (last_transition_created - DateTime.now).abs > community.subscription_dead_days_interval.days
  end

  def last_transition
    transitions.order(:sort_key).last
  end

  def next_transaction_charge_date
    if last_charge
      return (last_charge.created_at + 1.month)
    end

    DateTime.now
  end

  def last_charge
    @last_charge ||= donations.paid.ordered.first
  end

  def last_donation
    last_donation ||= donations.ordered.first
  end

  def customer
    return {
      "id" => gateway_customer_id
    } if gateway_customer_id.present?

    if last_charge && last_charge.gateway_data.try(:[], 'customer').try(:[], 'id').present?
      return last_charge.gateway_data["customer"]
    end

    donations.where("gateway_data is not null").last.try(:gateway_data).try(:[], 'customer')
  end

  def has_pending_payments?
    #%w(processing pending waiting_payment).include?(donations.last.try(:transaction_status))
    donations.where(%Q{
    transaction_id is not null AND (
    (payment_method = 'credit_card' and transaction_status in ('processing', 'pending'))
    OR (payment_method = 'boleto' and transaction_status in ('waiting_payment', 'pending', 'processing')
    and ((gateway_data->>'boleto_expiration_date')::timestamp + '2 days'::interval) >= now()))
                    }).order(id: :desc).limit(1).exists?
  end

  def payment_options_to_use card_hash = nil
    if payment_method == 'credit_card'
      (card_hash.present? ? { card_hash: card_hash } : { card_id: card_data["id"]})
    else
      { payment_method: 'boleto' }
    end
  end

  def canceled?
    current_state == 'canceled'
  end

  def unpaid?
    current_state == 'unpaid'
  end

  def charge_next_payment card_hash = nil
    if !canceled? && !has_pending_payments? && next_transaction_charge_date <= DateTime.now && customer
      donation = donations.create(
        widget_id: widget.id,
        cached_community_id: community.id,
        payment_method: payment_method,
        amount: amount,
        email: activist.email,
        transaction_status: 'processing',
        activist: activist
      )
      transaction = PagarMe::Transaction.new(
        {
          customer: { id: customer["id"] },
          postback_url: Rails.application.routes.url_helpers.create_postback_url(protocol: 'https'),
          amount: amount,
          split_rules: base_rules,
          metadata: {
            widget_id: widget.id,
            mobilization_id: widget.mobilization.id,
            community_id: community.id,
            city: community.city,
            email: activist.email,
            donation_id: donation.id,
            local_subscription_id: self.id
          }
        }.merge(payment_options_to_use(card_hash)))
      transaction.charge

      donation.update_attributes(
        transaction_id: transaction.id,
        transaction_status: transaction.status,
        gateway_data: transaction.to_json,
        payables: transaction.payables.to_json
      )
      self.update_attributes(card_data: transaction.card.to_json) if transaction.card.present?
      self.update_attribute(:gateway_customer_id, transaction.customer.id) if transaction.customer.present?
      process_status_changes(transaction.status, transaction.try(:to_h))

      donation
    end
  end

  def base_rules
    if global_rule.recipient_id != community_rule.recipient_id
      [global_rule, community_rule]
    else
      [global_rule(percentage: 100)]
    end
  end

  def community_rule(options = {})
    recipient ||= community.recipient.pagarme_recipient_id
    PagarMe::SplitRule.new(
      {
        charge_processing_fee: false,
        liable: true,
        percentage: 87,
        recipient_id: recipient
      }.merge!(options)
    )
  end

  def global_rule(options = {})
    PagarMe::SplitRule.new(
      {
        charge_processing_fee: true,
        liable: false,
        percentage: 13,
        recipient_id: ENV['ORG_RECIPIENT_ID']
      }.merge!(options)
    )
  end

  def notify_activist(template_name, template_vars = {}, auto_deliver = true)
    Notification.notify!(
      activist_id,
      template_name,
      default_template_vars.merge(template_vars),
      community_id,
      auto_deliver)
  end

  def process_status_changes(status, data)
    case status
    when 'paid'
      transition_to(:paid, donation_data: data)
    when 'refused'
      transition_to(:unpaid, donation_data: data)
    when 'waiting_payment'
      transition_to(:waiting_payment, donation_data: data)
      notify_activist(:slip_subscription)
    end
  end

  def default_template_vars
    global = {
      subscription_id: id,
      activist_id: activist_id,
      amount: ( amount / 100),
      manage_url: "https://app.bonde.org/subscriptions/#{id}/edit?token=#{token}",
      community: {
        id: community_id,
        name: community.name,
        image: community.image
      },
      customer: {
        name: activist.name,
        first_name: activist.name.split(' ').try(:first)
      }
    }

    if last_donation.present?
      global.merge!(
        last_donation: {
          payment_method: payment_method,
          widget_id: last_donation.widget_id,
          mobilization_id: last_donation.mobilization.try(:id),
          mobilization_name: last_donation.mobilization.try(:name),
          boleto_expiration_date: last_donation.gateway_data.try(:[], 'boleto_expiration_date'),
          boleto_barcode: last_donation.gateway_data.try(:[], 'boleto_barcode'),
          boleto_url: last_donation.gateway_data.try(:[], 'boleto_url'),
        }
      )
    end
  end

  def mailchimp_add_active_donators
    subscribe_to_list(self.activist.email, subscribe_attributes)
    widget.create_mailchimp_donators_segments
    widget.reload
    
    email_status = status_on_list(activist.email)
    subscribe_to_segment(widget.mailchimp_recurring_active_segment_id, activist.email) if email_status == :subscribed
  end

  def mailchimp_remove_from_active_donators
    email_status = status_on_list(activist.email)
    raise StandardError.new('Unsubscribed') if email_status == :not_registred
    if email_status == :subscribed
      unsubscribe_from_segment widget.mailchimp_recurring_active_segment_id, activist.email
      subscribe_to_segment widget.mailchimp_recurring_inactive_segment_id, activist.email
    end
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

  def new_card_from_hash card_hash
    return unless card_hash.present?

    PagarMe::Card.create(card_hash: card_hash)
  rescue Exception => e
    self.errors.add(:card_data, e.message)
  end
  def new_customer_from_customer_data data
    return unless data.present?

    PagarMe::Customer.create(data)
  rescue Exception => e
    self.errors.add(:customer_data, e.message)
  end

end
