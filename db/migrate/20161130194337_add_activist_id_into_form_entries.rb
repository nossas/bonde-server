class AddActivistIdIntoFormEntries < ActiveRecord::Migration
  def change
    add_column :form_entries, :activist_id, :integer, index: true
    add_foreign_key :form_entries, :activists
  end
end
