class ChangeFacebookBotRecipientsTableViewToPostgraphql < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE VIEW postgraphql.bot_recipients AS
SELECT
  i.facebook_bot_configuration_id,
  i.fb_context_recipient_id,
  i.fb_context_sender_id,
  i.interaction,
  c.community_id,
  c.data AS facebook_bot_configuration,
  i.created_at
FROM postgraphql.facebook_activist_interactions AS i
LEFT JOIN postgraphql.facebook_activist_interactions AS aux ON (
  i.facebook_bot_configuration_id = aux.facebook_bot_configuration_id
  AND i.fb_context_recipient_id = aux.fb_context_recipient_id
  AND i.fb_context_sender_id = aux.fb_context_sender_id
  AND i.id < aux.id
)
LEFT JOIN facebook_bot_configurations AS c ON i.facebook_bot_configuration_id = c.id
WHERE aux.id IS NULL
  AND postgraphql.current_user_has_community_participation(c.community_id);
}
  end

  def down
    execute %Q{
CREATE OR REPLACE VIEW postgraphql.bot_recipients AS
SELECT
  i.facebook_bot_configuration_id,
  i.fb_context_recipient_id,
  i.fb_context_sender_id,
  i.interaction,
  c.community_id,
  c.data AS facebook_bot_configuration,
  i.created_at
FROM activist_facebook_bot_interactions AS i
LEFT JOIN activist_facebook_bot_interactions AS aux ON (
  i.facebook_bot_configuration_id = aux.facebook_bot_configuration_id
  AND i.fb_context_recipient_id = aux.fb_context_recipient_id
  AND i.fb_context_sender_id = aux.fb_context_sender_id
  AND i.id < aux.id
)
LEFT JOIN facebook_bot_configurations AS c ON i.facebook_bot_configuration_id = c.id
WHERE aux.id IS NULL
  AND postgraphql.current_user_has_community_participation(c.community_id);
}
  end
end
