class AddProfileDataToCommunityActivist < ActiveRecord::Migration
  def change
    add_column :community_activists, :profile_data, :jsonb
  end
end
