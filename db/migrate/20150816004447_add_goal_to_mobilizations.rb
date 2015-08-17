class AddGoalToMobilizations < ActiveRecord::Migration
  def change
    add_column :mobilizations, :goal, :text
  end
end
