class CreateGatewayTransactions < ActiveRecord::Migration
  def change
    create_table :gateway_transactions do |t|
      t.text :transaction_id
      t.jsonb :gateway_data

      t.timestamps null: false
    end
  end
end
