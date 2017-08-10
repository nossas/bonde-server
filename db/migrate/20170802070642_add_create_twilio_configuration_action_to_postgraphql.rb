class AddCreateTwilioConfigurationActionToPostgraphql < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE VIEW postgraphql.twilio_configurations AS
SELECT * FROM public.twilio_configurations;

GRANT INSERT, SELECT, UPDATE, DELETE ON postgraphql.twilio_configurations
TO ADMIN, common_user;

GRANT USAGE ON sequence twilio_configurations_id_seq
TO ADMIN, common_user;

CREATE OR REPLACE FUNCTION postgraphql.add_twilio_configuration (CONFIG postgraphql.twilio_configurations)
RETURNS postgraphql.twilio_configurations
LANGUAGE plpgsql AS $$
  DECLARE twilio_configuration postgraphql.twilio_configurations;
  BEGIN
    INSERT INTO postgraphql.twilio_configurations (
      community_id,
      twilio_account_sid,
      twilio_auth_token,
      twilio_number,
      created_at,
      updated_at
    ) VALUES (
      CONFIG.community_id,
      CONFIG.twilio_account_sid,
      CONFIG.twilio_auth_token,
      CONFIG.twilio_number,
      now(),
      now()
    ) RETURNING * INTO twilio_configuration;
    RETURN twilio_configuration;
  END;
$$;
}
  end

  def down
    execute %Q{
DROP FUNCTION postgraphql.add_twilio_configuration (CONFIG postgraphql.twilio_configurations);

REVOKE USAGE ON sequence twilio_configurations_id_seq
FROM ADMIN, common_user;

REVOKE INSERT, SELECT, UPDATE, DELETE ON postgraphql.twilio_configurations
FROM ADMIN, common_user;

DROP VIEW postgraphql.twilio_configurations;
}
  end
end
