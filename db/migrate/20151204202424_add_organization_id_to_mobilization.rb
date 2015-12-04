class AddOrganizationIdToMobilization < ActiveRecord::Migration
  def change
    add_column :mobilizations, :organization_id, :integer
  end
end
