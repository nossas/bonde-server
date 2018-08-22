class AddFieldsToActivistPressure < ActiveRecord::Migration
  def change
    add_column :activist_pressures, :mail, :jsonb
    add_column :activist_pressures, :firstname, :text
    add_column :activist_pressures, :lastname, :text
  end
end
