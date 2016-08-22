class CreateActivistPressures < ActiveRecord::Migration
  def change
    create_table :activist_pressures do |t|
      t.references :activist, index: true, foreign_key: true
      t.references :widget, index: true, foreign_key: true
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps null: false
    end
  end
end
