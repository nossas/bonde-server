class AddNotificationTypeToNotifications < ActiveRecord::Migration
  def up
    remove_column :notifications, :auto_fire
    add_column :notifications, :notification_type, :string
  end

  def down
    add_column :notifications, :auto_fire, :boolean, default: false
    remove_column :notifications, :notification_type, :string
  end
end
