class CreateDnsHostedZones < ActiveRecord::Migration
  def change
    create_table :dns_hosted_zones do |t|
      t.integer :community_id, nullable: false
      t.string :domain_name, nullable: false
      t.text :comment
      t.string :hosted_zone_id

      t.timestamps null: false
    end
    add_foreign_key :dns_hosted_zones, :communities
    add_index :dns_hosted_zones, :domain_name, unique: true
  end
end
