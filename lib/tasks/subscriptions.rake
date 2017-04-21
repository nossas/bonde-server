namespace :subscriptions do
  desc "charge on all subscriptions"
  task schedule_charges: [:environment] do
    Subscription.find_each do |subscription|
      Resque.enqueue(SubscriptionWorker, subscription.id)
    end
  end
end
