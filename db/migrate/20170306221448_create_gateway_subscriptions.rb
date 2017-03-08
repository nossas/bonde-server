class CreateGatewaySubscriptions < ActiveRecord::Migration
  def change
    create_table :gateway_subscriptions do |t|
      t.integer :subscription_id, index: { unique: true }
      t.jsonb :gateway_data

      t.timestamps null: false
    end
  end
end
