class SubscriptionWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(subscription_id, last_unpaid_id = nil)
    subscription = Subscription.find subscription_id

    return if !last_unpaid_id.nil? && subscription.last_transition.try(:id) != last_unpaid_id

    subscription.charge_next_payment
    subscription.reload

    SubscriptionWorker.perform_at(
      subscription.next_transaction_charge_date,
      subscription.id
    ) unless subscription.has_pending_payments?
  end
end
