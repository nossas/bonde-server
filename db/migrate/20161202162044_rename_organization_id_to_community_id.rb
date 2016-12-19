class RenameOrganizationIdToCommunityId < ActiveRecord::Migration
  def change
    rename_column :payable_transfers, :organization_id, :community_id
    rename_column :template_mobilizations, :organization_id, :community_id
    rename_column :mobilizations, :organization_id, :community_id
  end
end
