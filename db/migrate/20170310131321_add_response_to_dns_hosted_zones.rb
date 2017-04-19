class AddResponseToDnsHostedZones < ActiveRecord::Migration
  def change
    add_column :dns_hosted_zones, :response, :jsonb
    remove_column :dns_hosted_zones, :hosted_zone_id, :string
  end
end
