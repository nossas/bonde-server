class AddPayableTransferIdInDonations < ActiveRecord::Migration
  def change
    add_reference :donations, :payable_transfer, index: true
    add_foreign_key :donations, :payable_transfers
  end
end
