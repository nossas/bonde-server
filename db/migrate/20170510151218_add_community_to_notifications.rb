class AddCommunityToNotifications < ActiveRecord::Migration
  def change
    add_reference :notifications, :community, index: true, foreign_key: true
    add_column :communities, :email_template_from, :string
  end
end
