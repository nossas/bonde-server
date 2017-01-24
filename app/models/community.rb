class Community < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  
  has_many :payable_transfers
  has_many :payable_details
  has_many :mobilizations
  has_many :community_users
  has_many :users, through: :community_users
  has_many :agg_activists
  has_many :recipients


  def total_to_receive_from_subscriptions
    @total_to_receive_from_subscriptions ||= subscription_payables_to_transfer.sum(:value_without_fee)
  end

  def subscription_payables_to_transfer
    @subscription_payables_to_transfer ||= payable_details.is_paid.from_subscription.over_limit_to_transfer
  end

  def update_from_pagarme
    raise PagarMe::PagarMeError.new "pagarme_recipient_id is empty" if not self.pagarme_recipient_id 
    
    recipient_info = PagarMe::Recipient.find_by_id self.pagarme_recipient_id

    self.transfer_day = recipient_info.transfer_day
    self.transfer_enabled = recipient_info.transfer_enabled
    self.recipient = recipient_info.as_json
  end
end
