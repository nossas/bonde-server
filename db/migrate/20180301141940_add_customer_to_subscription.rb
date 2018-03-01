class AddCustomerToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :customer_data, :jsonb
    add_column :subscriptions, :schedule_next_charge_at, :datetime
  end
end
