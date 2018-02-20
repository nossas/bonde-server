class AddDeliverAndDeliveredAtToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :deliver_at, :datetime
    add_column :notifications, :delivered_at, :datetime
  end
end
