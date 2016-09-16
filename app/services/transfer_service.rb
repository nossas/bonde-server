require 'pagarme'

class TransferService
  def self.sync_transferred_donations(org_id)
    self.new(org_id).sync_transferred_donations
  end

  def initialize(org_id)
    @organization ||= Organization.find org_id
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
              payable_transfer = @organization.payable_transfers.find_or_create_by(
                transfer_id: movement_object.id)

              payable_transfer.update_attributes(
                transfer_data: movement_object.to_json,
                transfer_status: movement_object.status,
                amount: movement_object.amount / 100.0
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
