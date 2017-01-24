class CreateRecipients < ActiveRecord::Migration
  def change
    create_table :recipients do |t|
      t.string :pagarme_recipient_id  , null: false
      t.jsonb :recipient              , null: false
      t.integer :community_id         , null: false
      t.integer :transfer_day
      t.boolean :transfer_enabled     , default: false

      t.timestamps null: false
    end

    add_foreign_key :recipients, :communities
  end
end
