class CreateTemplateBlocks < ActiveRecord::Migration
  def change
    create_table :template_blocks do |t|
      t.integer :template_mobilization_id
      t.string :bg_class
      t.integer :position
      t.boolean :hidden
      t.text :bg_image
      t.string :name
      t.boolean :menu_hidden

      t.timestamps null: false
    end
  end
end
