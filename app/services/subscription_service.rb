require 'pagarme'

class SubscriptionService < DonationService
  PLAN_NAMES = {"30": "Plano Mensal", "180": "Plano Semestral", "365": "Plano Anual"}

  def self.find_or_create_plans(widget)
    widget.donation_values.each do |value|
      period = widget.settings["recurring_period"] || "30"
      plan_name = "#{PLAN_NAMES[:"#{period}"]} #{value}"
      plan = Plan.find_by_name(plan_name)

      return plan unless plan.nil?

      plan = PagarMe::Plan.new({
        name: plan_name,
        amount: value.to_i * 100,
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
