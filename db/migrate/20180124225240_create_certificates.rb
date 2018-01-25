class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
      t.integer :community_id
      t.integer :mobilization_id
      t.integer :dns_hosted_zones_id
      t.string :domain
      t.text :file_content
      t.datetime :expire_on
      t.boolean :is_active
      t.timestamps
    end
  end
end
