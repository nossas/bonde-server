class CreateTwilioConfigurations < ActiveRecord::Migration
  def change
    create_table :twilio_configurations do |t|
      t.references :community, null: false
      t.text :twilio_account_sid, null: false
      t.text :twilio_auth_token, null: false
      t.text :twilio_number, null: false

      t.timestamps null: false

      t.index :community_id, unique: true
    end
  end
end
