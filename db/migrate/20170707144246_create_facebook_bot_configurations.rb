class CreateFacebookBotConfigurations < ActiveRecord::Migration
  def change
    create_table :facebook_bot_configurations do |t|
      t.references :community
      t.text :messenger_app_secret, null: false
      t.text :messenger_validation_token, null: false
      t.text :messenger_page_access_token, null: false
      t.jsonb :data, null: false, default: '{}'

      t.timestamps null: false
    end
  end
end
