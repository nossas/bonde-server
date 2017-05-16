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

  desc "Sync all not subscription donations transfer"
  task sync_transfer_donations: [:environment] do
    Organization.where("pagarme_recipient_id is not null").each do |org|
      begin
      TransferService.sync_transferred_donations(org.id)
      rescue Exception => e
        Rails.logger.info "Could not sync for organization -> #{org.id} | #{e.inspect}"
      end
    end
  end

  desc 'sync all gateway payments'
  task sync_gateway_transactions: :environment do
    page = 1
    per_page = 200

    loop do
      Rails.logger.info "[GatewayTransaction SYNC] -> running on page #{page}"

      transactions = PagarMe::Transaction.all(page, per_page)

      if transactions.empty?
        Rails.logger.info "[GatewayTransaction SYNC] -> exiting no transactions returned"
        break
      end

      transactions.each do |transaction| 
        transaction = GatewayTransaction.find_or_create_by transaction_id: transaction.id.to_s
        transaction.update_attributes(
          gateway_data: transaction.to_json
        )
        print '.'
      end

      Rails.logger.info "[GatewayPayment SYNC] - transactions synced on page #{page}"

      page = page+1
    end
  end

end
