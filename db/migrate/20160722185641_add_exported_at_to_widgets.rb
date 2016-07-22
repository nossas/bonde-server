class AddExportedAtToWidgets < ActiveRecord::Migration
  def change
    add_column :widgets, :exported_at, :datetime
  end
end
