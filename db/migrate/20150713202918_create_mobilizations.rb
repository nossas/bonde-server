class CreateMobilizations < ActiveRecord::Migration
  def change
    create_table :mobilizations do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
