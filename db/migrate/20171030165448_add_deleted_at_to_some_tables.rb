class AddDeletedAtToSomeTables < ActiveRecord::Migration
  def change
    add_column :blocks, :deleted_at, :timestamp
    add_column :mobilizations, :deleted_at, :timestamp
    add_column :widgets, :deleted_at, :timestamp
    add_column :communities, :mailchimp_sync_request_at, :timestamp
  end
end
