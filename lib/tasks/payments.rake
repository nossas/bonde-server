namespace :payments do
  desc "Sync all transaction status and new payments from all subscriptions"
  task sync_subscriptions: [:environment] do
    Donation.unscoped.where("subscription and parent_id is null").order('donations.id asc').find_each do |resource| 
      if resource.subscription_id.present?
        Rails.logger.info "Start sync for subscription -> #{resource.subscription_id}"
        SubscriptionSyncService.sync(resource.subscription_id)
      end
    end
  end

  desc "Sync all donations status and data"
  task sync_donations: [:environment] do
    Donation.unscoped.where("not subscription and transaction_id is not null").order('donations.id desc').find_each do |resource| 
      begin
        Rails.logger.info "Start sync for  donation -> #{resource.transaction_id}"
        DonationService.update_from_gateway(resource)
      rescue Expiration => e
        Rails.logger.info "Donation #{resource.transaction_id} not synched #{e.inspect}"
      end
    end
  end

    end
  end
end
