namespace :subscriptions do
  desc "charge on all subscriptions"
  task schedule_charges: [:environment] do
    Subscription.find_each do |subscription|
      begin
        Rails.logger.info "Starting subscription schedule -> #{subscription.id}"
        SubscriptionSchedulesService.schedule_charges(subscription)
      rescue Exception => e
        Rails.logger.info "Subscription #{subscription.id} not synched #{e.inspect}"
      end
    end
  end
end
