class AddCardHashToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :card_hash, :string
  end
end
