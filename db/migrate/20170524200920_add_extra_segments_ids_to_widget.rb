class AddExtraSegmentsIdsToWidget < ActiveRecord::Migration
  def change
    add_column :widgets, :mailchimp_unique_segment_id, :string
    add_column :widgets, :mailchimp_recurring_active_segment_id, :string
    add_column :widgets, :mailchimp_recurring_inactive_segment_id, :string
  end
end
