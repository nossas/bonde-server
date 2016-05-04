class AddCustomerToDonations < ActiveRecord::Migration
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    add_column :donations, :customer, :hstore
    add_index :donations, :customer, using: :gin
  end
end
