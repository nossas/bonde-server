class Subscription < ActiveRecord::Base
  belongs_to :widget
  belongs_to :activist
  belongs_to :community

  has_many :donations, foreign_key: :local_subscription_id

  validates :widget, :activist, :community, :amount, presence: true

  def next_transaction_charge_date
    if last_charge
      return (last_charge.created_at + 1.month)
    end

    DateTime.now
  end

  def last_charge
    @last_charge ||= donations.paid.ordered.first
  end

  def customer
    if last_charge
      return last_charge.gateway_data["customer"]
    end

    donations.where("gateway_data is not null").last.gateway_data["customer"]
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
end
