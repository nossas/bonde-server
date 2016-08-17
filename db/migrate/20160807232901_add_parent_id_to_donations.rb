class AddParentIdToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :parent_id, :integer
  end
end
