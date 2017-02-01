class ImportFromCommunityToRecipient < ActiveRecord::Migration
  def up
    Community.transaction do
      Community.where('pagarme_recipient_id_old is not null').order(:id).each do |community|
        recipient = Recipient.new 
        recipient.community = community
        recipient.pagarme_recipient_id = community.pagarme_recipient_id_old
        recipient.recipient = community.pagarme_recipient
        recipient.transfer_day = community.pagarme_transfer_day
        recipient.transfer_enabled = community.pagarme_transfer_enabled
        recipient.save!
        community.recipient = recipient
        community.save!
      end
    end
  end

  def down 
    Community.transaction do
      Community.where('recipient_id is not null').each do |community|
        community.pagarme_recipient_id_old = community.recipient.pagarme_recipient_id
        community.pagarme_recipient = community.recipient.recipient
        community.pagarme_transfer_day = community.recipient.transfer_day
        community.pagarme_transfer_enabled = community.recipient.transfer_enabled
        community.save!
      end
    end
  end
end
