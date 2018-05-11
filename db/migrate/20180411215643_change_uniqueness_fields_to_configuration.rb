class ChangeUniquenessFieldsToConfiguration < ActiveRecord::Migration
  def change
    add_index :configurations, :name, unique: true
  end
end
