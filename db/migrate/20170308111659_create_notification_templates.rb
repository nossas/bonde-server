class CreateNotificationTemplates < ActiveRecord::Migration
  def change
    create_table :notification_templates do |t|
      t.text :label, null: false
      t.integer :community_id
      t.text :subject_template, null: false
      t.text :body_template, null: false
      t.jsonb :template_vars

      t.timestamps null: false
    end

    add_foreign_key :notification_templates, :communities
  end
end
