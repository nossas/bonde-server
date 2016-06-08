class AddTransactionInfoToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :transaction_id, :string
    add_column :donations, :transaction_status, :string
  end
end
