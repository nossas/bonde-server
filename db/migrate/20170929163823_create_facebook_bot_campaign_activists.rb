class CreateFacebookBotCampaignActivists < ActiveRecord::Migration
  def change
    create_table :facebook_bot_campaign_activists do |t|
      t.references(
        :facebook_bot_campaign,
        index: { name: 'idx_facebook_bot_campaign_activists_on_facebook_bot_campaign_id' },
        foreign_key: true,
        null: false
      )
      t.references(
        :facebook_bot_activist,
        index: { name: 'idx_facebook_bot_campaign_activists_on_facebook_bot_activist_id' },
        foreign_key: true,
        null: false
      )
      t.boolean :received, null: false, default: false
      t.jsonb :log, default: "{}"

      t.timestamps null: false
    end
  end
end
