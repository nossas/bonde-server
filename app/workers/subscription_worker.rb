class SubscriptionWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(subscription_id, last_unpaid_id = nil)
    subscription = Subscription.find subscription_id

    if !last_unpaid_id.nil?
      transition = subscription.transitions.order(:sort_key).last
      return if transition.try(:id) != last_unpaid_id
    end

    subscription.charge_next_payment
    subscription.reload

    SubscriptionWorker.perform_at(
      subscription.next_transaction_charge_date,
      subscription.id
    ) unless subscription.has_pending_payments?
  end
end
