class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.references :activist, index: true
      t.text :last_digits
      t.text :card_brand
      t.text :card_key

      t.timestamps
    end
  end
end
