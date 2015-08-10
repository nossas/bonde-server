class AddMdSizeToWidget < ActiveRecord::Migration
  def change
    add_column :widgets, :md_size, :integer
  end
end
