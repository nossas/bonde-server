class AddNsOkToDnsHostedZone < ActiveRecord::Migration
  def change
    add_column :dns_hosted_zones, :ns_ok, :boolean
  end
end
