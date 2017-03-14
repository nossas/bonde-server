class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :activist, index: true, foreign_key: true, null: false
      t.references :notification_template, index: true, foreign_key: true, null: false
      t.jsonb :template_vars

      t.timestamps null: false
    end
  end
end
