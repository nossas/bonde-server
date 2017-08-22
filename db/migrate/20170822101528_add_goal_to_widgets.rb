class AddGoalToWidgets < ActiveRecord::Migration
  def change
    add_column :widgets, :goal, :decimal, precision: 8, scale: 2
  end
end
