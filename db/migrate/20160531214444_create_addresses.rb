class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :zipcode
      t.string :street
      t.string :street_number
      t.string :complementary
      t.string :neighborhood
      t.string :city
      t.string :state

      t.timestamps null: false
    end
  end
end
