class CreateActivists < ActiveRecord::Migration
  def change
    create_table :activists do |t|
      t.string :first_name, null: false
      t.string :last_name
      t.string :email, null: false
      t.string :phone
      t.string :document_number
      t.string :document_type

      t.timestamps null: false
    end
  end
end
