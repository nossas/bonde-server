require 'pagarme'

class TransferService
  def self.request_subscriptions_transfer(org_id)
    self.new(org_id).request_transfer_for_subscriptions
  end

  def self.sync_transferred_donations(org_id)
    self.new(org_id).sync_transferred_donations
  end

  def self.make_transfer(payable_transfer_id)
    payable_transfer = PayableTransfer.find payable_transfer_id
    return if payable_transfer.transfer_id.present?

    PayableTransfer.transaction do
      transfer = PagarMe::Transfer.create(
        recipient_id: payable_transfer.organization.pagarme_recipient_id,
        amount: (payable_transfer.amount * 100.0).to_i
      )

      payable_transfer.update_attributes(
        transfer_status: transfer.status,
        transfer_data: transfer.to_json,
        transfer_id: transfer.id
      )
    end
  end

  def initialize(org_id)
    @organization ||= Organization.find org_id
  end

  def request_transfer_for_subscriptions
    return unless @organization.transfer_enabled?

    if @organization.pagarme_recipient_id.present?
      if DateTime.now.day >= (@organization.transfer_day || 5) && @organization.subscription_payables_to_transfer.exists?
        PayableTransfer.transaction do
          payable_transfer = @organization.payable_transfers.create(
            amount: @organization.total_to_receive_from_subscriptions,
            transfer_status: 'pending'
          )
          @organization.subscription_payables_to_transfer.each do |payment|
            payment.donation.update_attribute(:payable_transfer_id, payable_transfer.id)
          end
        end
      end
    else
      Rails.logger.info "[TransferService] Organization #{@organization.id} has not recipient_id"
    end
  end

  # Sync with pagarme all donations that already transferred
  def sync_transferred_donations
    PayableTransfer.transaction do
      with_recipient do |recipient| 
        page = 1
        payable_transfer = nil

        loop do
          operations = recipient.balance_operations(page, 200)
          break if operations.empty?

          operations.each do |operation|
            movement_object = operation.movement_object
            if operation["type"] == 'transfer'
              payable_transfer = @organization.payable_transfers.find_by(transfer_id: movemet_object.id)

              if payable_transfer.nil?
                payable_transfer = @organization.payable_transfers.create(
                  transfer_id: movement_object.id,
                  amount: operation.amount / 100.0
                )
              end

              payable_transfer.update_attributes(
                transfer_data: movement_object.to_json,
                transfer_status: movement_object.status,
                amount: operation.amount / 100.0
              )
            end

            if payable_transfer.present? && operation["type"] == 'payable'
              donation = Donation.find_by_transaction_id movement_object.transaction_id
              puts "donation #{donation.id}"
              donation.payable_transfer = payable_transfer
              donation.save
            end
          end
          sleep 0.5
          page = page+1
        end
      end
    end
  end

  def with_recipient
    if @organization.pagarme_recipient_id.present?
      recipient ||= PagarMe::Recipient.find_by_id @organization.pagarme_recipient_id
      yield recipient
    else
      Rails.logger.info "[TransferService] Organization #{@organization.id} has not recipient_id"
    end
  end
end
