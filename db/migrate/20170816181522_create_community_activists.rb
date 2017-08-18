class CreateCommunityActivists < ActiveRecord::Migration
  def change
    create_table :community_activists do |t|
      t.references :community, index: true, foreign_key: true, null: false
      t.references :activist, index: true, foreign_key: true, null: false
      t.tsvector :search_index

      t.timestamps null: false
    end

    add_index :community_activists, [:community_id, :activist_id], unique: true
  end
end
