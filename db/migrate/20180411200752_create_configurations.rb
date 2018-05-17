class CreateConfigurations < ActiveRecord::Migration
  def change
    create_table :configurations do |t|
      t.string :name, null: false
      t.text :value, null: false

      t.timestamps null: false
    end
  end
end
