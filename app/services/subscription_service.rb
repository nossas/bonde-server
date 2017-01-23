require 'pagarme'

class SubscriptionService < DonationService
  include Rails.application.routes.url_helpers

  PLAN_NAMES = {"30": "Plano Mensal", "180": "Plano Semestral", "365": "Plano Anual"}

  def self.run(donation, address)
    self.create_subscription(donation, address)
  end

  def self.create_plans(widget)
    widget.donation_values.each do |value|
      period = widget.settings["recurring_period"] || "30"
      plan_name = "#{PLAN_NAMES[:"#{period}"]} #{value}"
      amount = value.to_i * 100
      plan = Plan.find_by(name: plan_name, days: period, amount: amount)

      if plan.nil?
        plan = PagarMe::Plan.new({
          name: plan_name,
          amount: amount,
          days: period
        })

        if plan.create
          Plan.create(
            name: plan.name,
            amount: plan.amount,
            days: period,
            plan_id: plan.id
          )
        end
      end
    end
  end

  def self.new_subscription(donation)
    period = donation.period || "30"
    plan = Plan.find_by(days: period, amount: donation.amount)

    self.find_or_create_card(donation) unless donation.boleto?

    PagarMe::Subscription.new({
      payment_method: donation.payment_method,
      card_id: donation.credit_card,
      plan_id: plan.plan_id,
      postback_url: Rails.application.routes.url_helpers.create_postback_url,
      metadata: {
        widget_id: donation.widget.id,
        mobilization_id: donation.mobilization.id,
        community_id: donation.community.id,
        city: donation.community.city,
        email: donation.activist.email,
        donation_id: donation.id
      }
    })
  end

  def self.create_subscription(donation, address)
    ActiveRecord::Base.transaction do
      subscription = self.new_subscription(donation)
      subscription.customer = self.customer_params(donation, address)
      donation.email = donation.activist.email
      donation.save

      begin
        subscription.create
        current_transaction = subscription.try(:current_transaction)
        donation.update_attributes(
          subscription_id: subscription.id,
          plan_id: Plan.find_by_plan_id(subscription.plan.id).id,
          transaction_id: current_transaction.try(:id),
          transaction_status: current_transaction.try(:status),
          gateway_data: current_transaction.try(:to_json),
          payables: current_transaction.try(:payables).try(:to_json)
        )
        self.create_payment(donation)
      rescue PagarMe::PagarMeError => e
        Raven.capture_exception(e) unless Rails.env.test?
        Rails.logger.error("\n==> SUBSCRIPTION ERROR: #{e.inspect}\n")
      end
    end
  end

  def self.create_payment(donation)
    card = CreditCard.find_by_card_id(donation.credit_card) if donation.credit_card

    donation.payments.create(
      transaction_status: donation.transaction_status,
      transaction_id: donation.transaction_id,
      plan_id: donation.plan_id,
      donation_id: donation.id,
      subscription_id: donation.subscription_id,
      activist_id: donation.activist_id,
      credit_card_id: card.try(:id)
    )
  end
end
