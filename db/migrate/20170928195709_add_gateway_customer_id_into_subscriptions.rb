class AddGatewayCustomerIdIntoSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :gateway_customer_id, :integer
  end
end
