class AddBgImageToBlocks < ActiveRecord::Migration
  def change
    add_column :blocks, :bg_image, :text
  end
end
