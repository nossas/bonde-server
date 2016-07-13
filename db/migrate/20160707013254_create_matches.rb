class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.references :widget, index: true, foreign_key: true
      t.string :first_choice
      t.string :second_choice
      t.string :goal_image
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps null: false
    end
  end
end
