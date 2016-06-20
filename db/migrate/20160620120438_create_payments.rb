class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :transaction_status
      t.string :transaction_id
      t.integer :plan_id
      t.belongs_to :donation, index: true
      t.string :subscription_id
      t.integer :activist_id
      t.integer :address_id
      t.integer :credit_card_id

      t.timestamps
    end
  end
end
