class RenameOrganizationsToCommunities < ActiveRecord::Migration
  def change
    rename_table :organizations, :communities
  end
end
