class CreatePayableTransfers < ActiveRecord::Migration
  def change
    create_table :payable_transfers do |t|
      t.integer :transfer_id
      t.jsonb :transfer_data
      t.text :transfer_status
      t.integer :organization_id, null: false
      t.decimal :amount, null: false


      t.timestamps null: false
    end
  end
end
