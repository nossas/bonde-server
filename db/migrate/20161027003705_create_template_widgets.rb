class CreateTemplateWidgets < ActiveRecord::Migration
  def change
    create_table :template_widgets do |t|
      t.integer :template_block_id
      t.jsonb :settings
      t.string :kind
      t.integer :sm_size
      t.integer :md_size
      t.integer :lg_size
      t.string :mailchimp_segment_id
      t.boolean :action_community
      t.timestamp :exported_at

      t.timestamps null: false
    end
  end
end
