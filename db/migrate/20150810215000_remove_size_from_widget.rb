class RemoveSizeFromWidget < ActiveRecord::Migration
  def change
    remove_column :widgets, :size, :integer
  end
end
