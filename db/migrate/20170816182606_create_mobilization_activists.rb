class CreateMobilizationActivists < ActiveRecord::Migration
  def change
    create_table :mobilization_activists do |t|
      t.references :mobilization, index: true, foreign_key: true, null: false
      t.references :activist, index: true, foreign_key: true, null: false
      t.tsvector :search_index

      t.timestamps null: false
    end

    add_index :mobilization_activists, [:mobilization_id, :activist_id], unique: true
  end
end
