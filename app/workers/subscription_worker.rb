class SubscriptionWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(subscription_id, last_unpaid_id = nil)
    subscription = Subscription.find subscription_id

    return if !last_unpaid_id.nil? && subscription.last_transition.try(:id) != last_unpaid_id
    return if subscription.canceled?

    subscription.charge_next_payment
    subscription.reload
  end
end
