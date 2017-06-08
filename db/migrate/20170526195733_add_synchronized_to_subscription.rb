class AddSynchronizedToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :synchronized, :boolean
  end
end
