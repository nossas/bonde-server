require 'pagarme'

class SubscriptionService < DonationService
  PLAN_NAMES = {"30": "Plano Mensal", "180": "Plano Semestral", "365": "Plano Anual"}

  def self.run(donation)
    self.create_subscription(donation)
  end

  def self.find_or_create_plans(widget)
    widget.donation_values.each do |value|
      period = widget.settings["recurring_period"] || "30"
      plan_name = "#{PLAN_NAMES[:"#{period}"]} #{value}"
      amount = value.to_i * 100
      plan = Plan.find_by(name: plan_name, days: period, amount: amount)

      return plan unless plan.nil?

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

  private

  def self.new_subscription(donation)
    period = donation.period || "30"
    plan = Plan.find_by(days: period, amount: donation.amount)
    self.find_or_create_card(donation) unless donation.boleto?

    PagarMe::Subscription.new({
      payment_method: donation.payment_method,
      card_id: donation.credit_card,
      plan_id: plan.plan_id,
      postback_url: 'http://requestb.in/rigksfri',
      customer: {
        email: donation.activist.email,
        name: donation.activist.name,
        phone: {
          ddd: self.phone(donation.activist.phone)[:ddd],
          number: self.phone(donation.activist.phone)[:number]
        }
      },
      metadata: {
        widget_id: donation.widget.id,
        mobilization_id: donation.mobilization.id,
        organization_id: donation.organization.id,
        city: donation.organization.city,
        email: donation.activist.email,
        donation_id: donation.id
      }
    })
  end

  def self.create_subscription(donation)
    ActiveRecord::Base.transaction do
      subscription = self.new_subscription(donation)

      begin
        subscription.create
        donation.update_attributes(subscription_id: subscription.id)
      rescue PagarMe::PagarMeError => e
        Rails.logger.error("\n==> SUBSCRIPTION ERROR: #{e.inspect}\n")
      end
    end
  end
end
