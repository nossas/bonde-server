class AddCheckoutDataToDonation < ActiveRecord::Migration
  def change
    add_column :donations, :checkout_data, :jsonb
  end
end
