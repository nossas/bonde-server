namespace :subscriptions do
  desc "charge on all subscriptions"
  task schedule_charges: [:environment] do
    Subscription.find_each do |subscription|
      current_state = subscription.current_state
      can_process = (
        current_state == 'paid' || (
          subscription.current_state == 'unpaid' &&
            !subscription.reached_retry_limit?))

      if can_process
        if subscription.next_transaction_charge_date <= DateTime.now
          SubscriptionWorker.perform_async(subscription.id)
        end
      end
    end
  end
end
