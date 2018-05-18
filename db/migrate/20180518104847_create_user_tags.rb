class CreateUserTags < ActiveRecord::Migration
  def change
    create_table :user_tags do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :tag_id

      t.timestamps null: false
    end
  end
end
