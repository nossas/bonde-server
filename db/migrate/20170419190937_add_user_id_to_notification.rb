class AddUserIdToNotification < ActiveRecord::Migration
  def up
    change_column :notifications, :activist_id, :integer, null: true
    add_column :notifications, :user_id, :integer, null:true
    add_foreign_key :notifications, :users
  end
  def down
    remove_foreign_key :notifications, :users
    remove_column :notifications, :user_id, :integer, null:true
    change_column :notifications, :activist_id, :integer, null: false
  end
end
