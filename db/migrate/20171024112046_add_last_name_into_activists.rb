class AddLastNameIntoActivists < ActiveRecord::Migration
  def change
    add_column :activists, :first_name, :text
    add_column :activists, :fast_name, :text
  end
end
