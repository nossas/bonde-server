class AddSynchronizedToActivistPressure < ActiveRecord::Migration
  def change
    add_column :activist_pressures, :synchronized, :boolean
  end
end
