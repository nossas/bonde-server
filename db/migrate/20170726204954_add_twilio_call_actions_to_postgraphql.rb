class AddTwilioCallActionsToPostgraphql < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE VIEW postgraphql.twilio_calls AS
SELECT *
FROM public.twilio_calls;

GRANT SELECT, INSERT, UPDATE, DELETE
ON postgraphql.twilio_calls TO admin, common_user, anonymous;

CREATE OR REPLACE FUNCTION postgraphql.add_twilio_call (CALL postgraphql.twilio_calls)
RETURNS postgraphql.twilio_calls
LANGUAGE plpgsql AS $$
  DECLARE twilio_calls postgraphql.twilio_calls;
  BEGIN
    INSERT INTO postgraphql.twilio_calls (
      activist_id,
      widget_id,
      "from",
      "to",
      created_at,
      updated_at
    ) VALUES (
      coalesce(CALL.activist_id, NULL),
      CALL.widget_id,
      CALL.from,
      CALL.to,
      now(),
      now()
    ) returning * INTO twilio_calls;
    RETURN twilio_calls;
  END;
$$;
}
  end

  def down
    execute %Q{
DROP FUNCTION postgraphql.add_twilio_call (CALL postgraphql.twilio_calls);

REVOKE SELECT, INSERT, UPDATE, DELETE
ON postgraphql.twilio_calls FROM admin, common_user, anonymous;

DROP VIEW postgraphql.twilio_calls;
}
  end
end
