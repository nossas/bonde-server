class AddUpdateTwilioConfigurationActionToPostgraphql < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION postgraphql.update_twilio_configuration (CONFIG postgraphql.twilio_configurations)
RETURNS postgraphql.twilio_configurations
LANGUAGE plpgsql AS $$
  DECLARE twilio_configuration postgraphql.twilio_configurations;
  BEGIN
    UPDATE postgraphql.twilio_configurations
    SET
      twilio_account_sid = COALESCE(
        CONFIG.twilio_account_sid,
        twilio_configuration.twilio_account_sid
      ),
      twilio_auth_token = COALESCE(
        CONFIG.twilio_auth_token,
        twilio_configuration.twilio_auth_token
      ),
      twilio_number = COALESCE(
        CONFIG.twilio_number,
        twilio_configuration.twilio_number
      ),
      updated_at = now()
    WHERE community_id = CONFIG.community_id
    RETURNING * INTO twilio_configuration;
    RETURN twilio_configuration;
  END;
$$;
}
  end

  def down
    execute %Q{
DROP FUNCTION postgraphql.update_twilio_configuration (CONFIG postgraphql.twilio_configurations);
}
  end
end
