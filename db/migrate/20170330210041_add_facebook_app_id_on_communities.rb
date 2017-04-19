class AddFacebookAppIdOnCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :facebook_app_id, :string
  end
end
