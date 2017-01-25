class DropOldColumnsOnCommunities < ActiveRecord::Migration
  def change
    remove_column :communities, :pagarme_recipient_id_old, :string
    remove_column :communities, :pagarme_recipient, :jsonb
    remove_column :communities, :pagarme_transfer_day, :integer
    remove_column :communities, :pagarme_transfer_enabled, :boolean, default:true
  end
end
