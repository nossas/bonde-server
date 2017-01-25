class Community < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  
  has_many :payable_transfers
  has_many :payable_details
  has_many :mobilizations
  has_many :community_users
  has_many :users, through: :community_users
  has_many :agg_activists
  has_many :recipients

  belongs_to :recipient

  def pagarme_recipient_id
    recipient.pagarme_recipient_id if recipient
  end

  def transfer_day
    recipient.transfer_day if recipient
  end

  def transfer_enabled
    recipient.transfer_enabled if recipient
  end

  def total_to_receive_from_subscriptions
    @total_to_receive_from_subscriptions ||= subscription_payables_to_transfer.sum(:value_without_fee)
  end

  def subscription_payables_to_transfer
    @subscription_payables_to_transfer ||= payable_details.is_paid.from_subscription.over_limit_to_transfer
  end
end
