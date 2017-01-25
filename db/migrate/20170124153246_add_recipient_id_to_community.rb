class AddRecipientIdToCommunity < ActiveRecord::Migration
  def change
    add_column :communities, :recipient_id, :integer
    add_foreign_key :communities, :recipients

    rename_column :communities, :recipient, :pagarme_recipient
    rename_column :communities, :pagarme_recipient_id, :pagarme_recipient_id_old
    rename_column :communities, :transfer_day, :pagarme_transfer_day
    rename_column :communities, :transfer_enabled, :pagarme_transfer_enabled
  end
end
