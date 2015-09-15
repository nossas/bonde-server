class AddFacebookShareImageToMobilization < ActiveRecord::Migration
  def change
    add_column :mobilizations, :facebook_share_image, :string
  end
end
