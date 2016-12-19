class AddImageAndDescriptionToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :image, :string
    add_column :communities, :description, :text
  end
end
