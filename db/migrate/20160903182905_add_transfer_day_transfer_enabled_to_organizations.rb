class AddTransferDayTransferEnabledToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :transfer_day, :integer
    add_column :organizations, :transfer_enabled, :boolean, default: false
  end
end
