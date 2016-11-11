class AddSynchronizedToFormEntries < ActiveRecord::Migration
  def change
    add_column :form_entries, :synchronized, :boolean
  end
end
