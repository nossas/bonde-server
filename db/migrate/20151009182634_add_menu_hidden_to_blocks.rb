class AddMenuHiddenToBlocks < ActiveRecord::Migration
  def change
    add_column :blocks, :menu_hidden, :boolean
  end
end
