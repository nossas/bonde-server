class CreateBalanceOperations < ActiveRecord::Migration
  def change
    create_table :balance_operations do |t|
      t.references :recipient, index: true, foreign_key: true, null: false
      t.jsonb :gateway_data, null: false
      t.bigint :gateway_id, null: false, unique: true

      t.timestamps null: false
    end
  end

end
