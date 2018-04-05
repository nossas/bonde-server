class AddCommunityIdToTwilioCalls < ActiveRecord::Migration
  def change
    add_column :twilio_calls, :community_id, :integer
  end
end
