class Subscription < ActiveRecord::Base
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
    if last_charge
      return last_charge.gateway_data["customer"]
    end

    donations.where("gateway_data is not null").last.gateway_data["customer"]
  end

  def has_pending_payments?
    %w(processing pending waiting_payment).include?(donations.last.try(:transaction_status))
  end

  def payment_options_to_use card_hash = nil
    if payment_method == 'credit_card'
      (card_hash.present? ? { card_hash: card_hash } : { card_id: card_data["id"]})
    else
      {}
    end
  end

  def charge_next_payment card_hash = nil
    if !has_pending_payments? && next_transaction_charge_date <= DateTime.now && customer
      donation = donations.create(
        widget_id: widget.id,
        payment_method: payment_method,
        amount: amount,
        email: activist.email,
        transaction_status: 'processing'
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

      case transaction.status
      when 'paid'
        transition_to(:paid, donation_data: transaction.try(:to_h))
      when 'refused'
        transition_to(:unpaid, donation_data: transaction.try(:to_h))
      end

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

  def notify_activist(template_name, template_vars = {})
    Notification.notify!(
      activist_id,
      template_name,
      default_template_vars.merge(template_vars))
  end

  def default_template_vars
    global = {
      subscription_id: id,
      activist_id: activist_id,
      amount: ( amount / 100),
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
end
