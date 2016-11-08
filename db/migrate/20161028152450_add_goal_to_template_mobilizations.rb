class AddGoalToTemplateMobilizations < ActiveRecord::Migration
  def change
    add_column :template_mobilizations, :goal, :text
  end
end
