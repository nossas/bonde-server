class AddMailchimpSegmentIdToWidget < ActiveRecord::Migration
  def change
    add_column :widgets, :mailchimp_segment_id, :string
  end
end
