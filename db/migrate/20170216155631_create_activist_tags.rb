class CreateActivistTags < ActiveRecord::Migration
  def change
    create_table :activist_tags do |t|
      t.integer :activist_id
      t.integer :community_id

      t.timestamps null: false
    end
    add_foreign_key :activist_tags, :activists
    add_foreign_key :activist_tags, :communities

    add_index :activist_tags, [:activist_id, :community_id], unique: true
  end
end
