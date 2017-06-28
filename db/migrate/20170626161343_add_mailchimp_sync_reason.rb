class AddMailchimpSyncReason < ActiveRecord::Migration
  def change
    add_column :donations, :mailchimp_syncronization_at, :datetime
    add_column :donations, :mailchimp_syncronization_error_reason, :text

    add_column :activist_pressures, :mailchimp_syncronization_at, :datetime
    add_column :activist_pressures, :mailchimp_syncronization_error_reason, :text

    add_column :form_entries, :mailchimp_syncronization_at, :datetime
    add_column :form_entries, :mailchimp_syncronization_error_reason, :text

    add_column :activist_matches, :mailchimp_syncronization_at, :datetime
    add_column :activist_matches, :mailchimp_syncronization_error_reason, :text

    add_column :subscriptions, :mailchimp_syncronization_at, :datetime
    add_column :subscriptions, :mailchimp_syncronization_error_reason, :text
  end
end
