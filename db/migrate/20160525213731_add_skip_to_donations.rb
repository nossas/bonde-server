class AddSkipToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :skip, :boolean, default: false
  end
end
