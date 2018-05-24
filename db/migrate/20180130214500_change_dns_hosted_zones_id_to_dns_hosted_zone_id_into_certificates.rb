class ChangeDnsHostedZonesIdToDnsHostedZoneIdIntoCertificates < ActiveRecord::Migration
    def up
        rename_column :certificates, :dns_hosted_zones_id, :dns_hosted_zone_id
    end
    def down
        rename_column :certificates, :dns_hosted_zone_id, :dns_hosted_zones_id
    end
  end