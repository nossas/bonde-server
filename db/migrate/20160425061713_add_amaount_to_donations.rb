class AddAmaountToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :amount, :integer
  end
end
