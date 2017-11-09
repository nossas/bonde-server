class CreateFacebookBotCampaigns < ActiveRecord::Migration
  def change
    create_table :facebook_bot_campaigns do |t|
      t.references :facebook_bot_configuration, index: true, foreign_key: true, null: false
      t.text :name, null: false
      t.jsonb :segment_filters, null: false
      t.integer :total_impacted_activists, null: false

      t.timestamps null: false
    end
  end
end
