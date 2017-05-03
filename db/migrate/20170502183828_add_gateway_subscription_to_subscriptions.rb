class AddGatewaySubscriptionToSubscriptions < ActiveRecord::Migration
  def change
    add_reference :subscriptions, :gateway_subscription
    add_foreign_key :subscriptions, :gateway_subscriptions
  end
end
