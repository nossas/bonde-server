class AddMoreIndexesOnActivists < ActiveRecord::Migration
  def change
    add_index :activists, :email
    add_index :activists, :created_at, order: { created_at: :desc }

    add_index :mobilizations, :community_id
    add_foreign_key :mobilizations, :communities
  end
end
