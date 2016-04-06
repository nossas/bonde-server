class AddActionCommunityToWidgets < ActiveRecord::Migration
  def change
    add_column :widgets, :action_community, :boolean, default: false
  end
end
