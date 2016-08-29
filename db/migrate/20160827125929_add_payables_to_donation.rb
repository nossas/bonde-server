class AddPayablesToDonation < ActiveRecord::Migration
  def change
    add_column :donations, :payables, :jsonb
  end
end
