class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :plan_id
      t.string :name
      t.integer :amount
      t.integer :days
      t.text :payment_methods, array: true, default: ['credit_card', 'boleto']

      t.timestamps
    end
  end
end
