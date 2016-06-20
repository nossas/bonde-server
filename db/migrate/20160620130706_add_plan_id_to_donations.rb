class AddPlanIdToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :plan_id, :integer
  end
end
