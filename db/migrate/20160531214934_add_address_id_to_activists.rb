class AddAddressIdToActivists < ActiveRecord::Migration
  def change
    change_table :activists do |t|
      t.references :address, index: true, foreign_key: true
    end
  end
end
