class SubscriptionWorker
  def self.perform(subscription_id)
    subscription = Subscription.find subscription_id
    subscription.charge_next_payment
  end
end
