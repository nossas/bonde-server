class AddFieldsToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :token, :string
    add_column :donations, :payment_method, :string
  end
end
