class CreateTwilioCallTransitions < ActiveRecord::Migration
  def change
    create_table :twilio_call_transitions do |t|
      t.text :twilio_account_sid, null: false
      t.text :twilio_call_sid, null: false
      t.text :twilio_parent_call_sid
      t.integer :sequence_number, null: false
      t.text :status, null: false
      t.text :called, null: false
      t.text :caller, null: false
      t.text :call_duration
      t.text :data, null: false

      t.timestamps null: false
    end
  end
end
