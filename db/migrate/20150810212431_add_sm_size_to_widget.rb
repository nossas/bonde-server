class AddSmSizeToWidget < ActiveRecord::Migration
  def change
    add_column :widgets, :sm_size, :integer
  end
end
