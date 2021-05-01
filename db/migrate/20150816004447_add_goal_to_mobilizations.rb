class AddGoalToMobilizations < ActiveRecord::Migration
  def change
    add_column :mobilizations, :goal, :text
    add_column :mobilizations, :language, :text
  end
end
