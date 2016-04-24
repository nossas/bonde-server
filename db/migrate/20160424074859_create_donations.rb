class CreateDonations < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.references :widget, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
