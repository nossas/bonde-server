class ChangeActivistsFields < ActiveRecord::Migration
  def change
    rename_column :activists, :first_name, :name
    remove_column :activists, :last_name
  end
end
