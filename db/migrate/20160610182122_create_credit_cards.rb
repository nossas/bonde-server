class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.references :activist, index: true
      t.string :last_digits
      t.string :card_brand
      t.string :card_id, null: false

      t.timestamps
    end
  end
end
