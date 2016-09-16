class AddGatewayDataToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :gateway_data, :jsonb
  end
end
