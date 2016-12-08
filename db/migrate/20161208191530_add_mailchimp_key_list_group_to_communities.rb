class AddMailchimpKeyListGroupToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :mailchimp_api_key, :text
    add_column :communities, :mailchimp_list_id, :text
    add_column :communities, :mailchimp_group_id, :text
  end
end
