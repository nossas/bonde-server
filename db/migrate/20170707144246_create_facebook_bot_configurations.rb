class CreateFacebookBotConfigurations < ActiveRecord::Migration
  def change
    create_table :facebook_bot_configurations do |t|
      t.refereces :community
      t.text :messenger_app_secret, null: false
      t.text :messenger_validation_token, null: false
      t.text :messenger_page_access_token, null: false
      t.jsonb :data

      t.timestamps null: false
    end
  end
end
