namespace :payments do
  desc "Sync all transaction status and new payments from all subscriptions"
  task sync_subscriptions: [:environment] do
    Donation.unscoped.where("subscription and parent_id is null").order('donations.id asc').find_each do |resource| 
      Rails.logger.info "Start sync for subscription -> #{resource.subscription_id}"
      SubscriptionSyncService.sync(resource.subscription_id)
    end
  end
end
