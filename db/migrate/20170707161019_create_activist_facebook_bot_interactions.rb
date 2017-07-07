class CreateActivistFacebookBotInteractions < ActiveRecord::Migration
  def change
    create_table :activist_facebook_bot_interactions do |t|
      t.references :ativist, index: true, foreign_key: true
      t.references :facebook_bot_configuration, index: true, foreign_key: true, null: false
      t.text :fb_context_recipient_id, null: false
      t.text :fb_context_sender_id, null: false
      t.jsonb :interaction, null: false

      t.timestamps null: false
    end
  end
end
