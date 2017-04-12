class AddConfigurableColumnsToCommunity < ActiveRecord::Migration
  def change
    add_column :communities, :subscription_retry_interval, :integer, default: 3
    add_column :communities, :subscription_dead_days_interval, :integer, default: 90
  end
end
