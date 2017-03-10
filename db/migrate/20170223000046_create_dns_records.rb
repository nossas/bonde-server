class CreateDnsRecords < ActiveRecord::Migration
  def change
    create_table :dns_records do |t|
      t.integer :dns_hosted_zone_id, nullable: false
      t.string :name, nullable: false
      t.string :record_type, nullable: false
      t.text :value, nullable: false
      t.integer :ttl, nullable: false

      t.timestamps null: false
    end
    add_foreign_key :dns_records, :dns_hosted_zones
    add_index :dns_records, [:name, :record_type], unique: true
  end
end
