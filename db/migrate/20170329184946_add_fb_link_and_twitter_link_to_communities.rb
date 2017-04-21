class AddFbLinkAndTwitterLinkToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :fb_link, :string
    add_column :communities, :twitter_link, :string
  end
end
