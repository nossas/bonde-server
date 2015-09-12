class CreateFormEntries < ActiveRecord::Migration
  def change
    create_table :form_entries do |t|
      t.references :widget, index: true, foreign_key: true
      t.text :fields

      t.timestamps null: false
    end
  end
end
