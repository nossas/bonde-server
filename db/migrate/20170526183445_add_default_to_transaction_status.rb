class AddDefaultToTransactionStatus < ActiveRecord::Migration
  def change
    change_column_default :donations, :transaction_status, 'pending'
  end
end
