class AddFacebookShareTitleToMobilization < ActiveRecord::Migration
  def change
    add_column :mobilizations, :facebook_share_title, :string
  end
end
