class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :community_id, nullable: false
      t.integer :user_id, nullable: false
      t.string :email, nullable: false
      t.string :code, nullable: false
      t.timestamp :expires, nullable: false
      t.integer :role, nullable: false
      t.boolean :expired, nullable: false

      t.timestamps null: false
    end
    add_foreign_key :invitations, :communities

    add_index :invitations, [:community_id, :code], unique: true
  end
end
