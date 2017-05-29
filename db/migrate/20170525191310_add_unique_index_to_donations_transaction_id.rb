class AddUniqueIndexToDonationsTransactionId < ActiveRecord::Migration
  def change
    add_index :donations, :transaction_id, unique: true
  end
end
