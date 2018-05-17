class FixFieldDnsHostedZoneIdInCertificates < ActiveRecord::Migration
  def change
    rename_column :certificates, :dns_hosted_zones_id, :dns_hosted_zone_id
  end
end
