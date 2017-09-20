class CreateFacebookBotActivists < ActiveRecord::Migration
  def change
    create_table :facebook_bot_activists do |t|
      t.text :fb_context_recipient_id, null: false
      t.text :fb_context_sender_id, null: false
      t.jsonb :data, null: false, default: '{}'
      t.tsvector :messages
      t.text :quick_replies, array: true, default: []
      t.datetime :interaction_dates, array: true, default: []

      t.timestamps null: false
    end

    add_index(
      :facebook_bot_activists,
      [:fb_context_recipient_id, :fb_context_sender_id],
      :unique => true,
      :name => 'index_facebook_bot_activists_on_recipient_id_and_sender_id'
    )
    add_index:facebook_bot_activists, :messages, using: :gin
    add_index:facebook_bot_activists, :quick_replies
    add_index:facebook_bot_activists, :interaction_dates
  end
end
