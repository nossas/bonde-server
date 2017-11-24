class AddComunityIdToDonationsActivistsPressuresFormEntries < ActiveRecord::Migration
  def change
    add_column :donations, :cached_community_id, :integer
    add_column :form_entries, :cached_community_id, :integer
    add_column :activist_pressures, :cached_community_id, :integer

    add_foreign_key :donations, :communities, column: :cached_community_id
    add_foreign_key :form_entries, :communities, column: :cached_community_id
    add_foreign_key :activist_pressures, :communities, column: :cached_community_id
  end
end
