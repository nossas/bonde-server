class AddBgClassToBlock < ActiveRecord::Migration
  def change
    add_column :blocks, :bg_class, :string
  end
end
