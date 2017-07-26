class CreateTwilioCalls < ActiveRecord::Migration
  def change
    create_table :twilio_calls do |t|
      t.references :activist
      t.references :widget, index: true, foreign_key: true
      t.text :twilio_account_sid
      t.text :twilio_call_sid
      t.text :from, null: false
      t.text :to, null: false
      t.jsonb :data, null: false, default: '{}'

      t.timestamps null: false
    end
  end
end
