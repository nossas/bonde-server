class AddLgSizeToWidget < ActiveRecord::Migration
  def change
    add_column :widgets, :lg_size, :integer
  end
end
