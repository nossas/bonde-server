class AddFacebookShareDescriptionToMobilization < ActiveRecord::Migration
  def change
    add_column :mobilizations, :facebook_share_description, :text
  end
end
