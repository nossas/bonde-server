class AddAutoFireToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :auto_fire, :boolean, default: false
  end
end
