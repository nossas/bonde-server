class AddConvertedFromToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :converted_from, :integer
  end
end
