class AddPeriodToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :period, :integer
  end
end
