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
        recipient_id: payable_transfer.community.pagarme_recipient_id,
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
    @community ||= Community.find org_id
  end

  def request_transfer_for_subscriptions
    return unless @community.transfer_enabled?

    if @community.pagarme_recipient_id.present?
      if DateTime.now.day >= (@community.transfer_day || 5) && @community.subscription_payables_to_transfer.exists?
        PayableTransfer.transaction do
          payable_transfer = @community.payable_transfers.create(
            amount: @community.total_to_receive_from_subscriptions,
            transfer_status: 'pending'
          )
          @community.subscription_payables_to_transfer.each do |payment|
            payment.donation.update_attribute(:payable_transfer_id, payable_transfer.id)
          end
        end
      end
    else
      Rails.logger.info "[TransferService] Community #{@community.id} has not recipient_id"
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

          payable_transfer sync_operations operations, payable_transfer 

          sleep 0.5
          page = page+1
        end
      end
    end
  end

  def with_recipient
    if @community.pagarme_recipient_id.present?
      recipient ||= PagarMe::Recipient.find_by_id @community.pagarme_recipient_id
      yield recipient
    else
      Rails.logger.info "[TransferService] Community #{@community.id} has not recipient_id"
    end
  end

  def self.register_bank_account data
    pagarme_bank_account = PagarMe::BankAccount.new({
      :bank_code => data[:bank_code],
      :agencia => data[:agencia],
      :agencia_dv => data[:agencia_dv],
      :conta => data[:conta],
      :conta_dv => data[:conta_dv],
      :type => data[:type],
      :legal_name => data[:legal_name],
      :document_number => data[:document_number]
    })

    pagarme_bank_account.create
    BankAccount.create!(pagarme_bank_account_id: pagarme_bank_account.id, data: pagarme_bank_account.to_json)
  end

  def self.register_recipient recipient_data
    PagarMe::Recipient.create( recipient_data )
  end

  def self.update_recipient pagarme_recipient_id, recipient_data
    pagarme_recipient = PagarMe::Recipient.new id: pagarme_recipient_id
    pagarme_recipient.transfer_interval = recipient_data['transfer_interval']
    pagarme_recipient.transfer_day = recipient_data['transfer_day']
    pagarme_recipient.transfer_enabled = recipient_data['transfer_enabled']
    if recipient_data['bank_account']
      pagarme_recipient.bank_account = recipient_data['bank_account']
    else
      pagarme_recipient.bank_account_id = recipient_data['bank_account_id']
    end
    pagarme_recipient.save
  end

  def self.update_recipient_info community
    recipient = PagarMe::Recipient.find_by_id community.pagarme_recipient_id
    community.transfer_day = recipient.transfer_day
    community.transfer_enabled = recipient.transfer_enabled
    community.recipient = recipient.as_json
    community.save
  end

  def self.remove_recipient recipient_id
    recipient = PagarMe::Recipient.new id: recipient_id
    recipient.destroy
  end

  private

  def sync_operations operations, payable_transfer
    operations.each do |operation|
      movement_object = operation.movement_object
      if operation["type"] == 'transfer'
        payable_transfer = @community.payable_transfers.find_by(transfer_id: movemet_object.id)

        if payable_transfer.nil?
          payable_transfer = @community.payable_transfers.create(
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
    payable_transfer
  end
end
