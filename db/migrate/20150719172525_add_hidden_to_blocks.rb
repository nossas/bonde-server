class AddHiddenToBlocks < ActiveRecord::Migration
  def change
    add_column :blocks, :hidden, :boolean
  end
end
