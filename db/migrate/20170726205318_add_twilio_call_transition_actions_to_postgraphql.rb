class AddTwilioCallTransitionActionsToPostgraphql < ActiveRecord::Migration
  def up
    execute %Q{
CREATE TYPE postgraphql.twilio_calls_arguments AS (
  activist_id integer,
  widget_id integer,
  "from" text,
  "to" text,
  twilio_call_sid text
);

CREATE TYPE postgraphql.watch_twilio_call_transition_record_set AS (
  widget_id integer,
  activist_id integer,
  twilio_call_id integer,
  twilio_call_account_sid text,
  twilio_call_call_sid text,
  twilio_call_from text,
  twilio_call_to text,
  twilio_call_transition_id integer,
  twilio_call_transition_sequence_number integer,
  twilio_call_transition_status text,
  twilio_call_transition_call_duration text,
  twilio_call_transition_created_at TIMESTAMP,
  twilio_call_transition_updated_at TIMESTAMP
);

CREATE OR REPLACE FUNCTION postgraphql.watch_twilio_call_transitions (CALL postgraphql.twilio_calls_arguments)
RETURNS postgraphql.watch_twilio_call_transition_record_set
LANGUAGE SQL AS $$
  SELECT tc.widget_id AS widget_id,
         tc.activist_id AS activist_id,
         tc.id AS twilio_call_id,
         tc.twilio_account_sid AS twilio_call_account_sid,
         tc.twilio_call_sid AS twilio_call_call_sid,
         tc."from" AS twilio_call_from,
         tc."to" AS twilio_call_to,
         tct.id AS twilio_call_transition_id,
         tct.sequence_number AS twilio_call_transition_sequence_number,
         tct.status AS twilio_call_transition_status,
         tct.call_duration AS twilio_call_transition_call_duration,
         tct.created_at AS twilio_call_transition_created_at,
         tct.updated_at AS twilio_call_transition_updated_at
  FROM public.twilio_calls AS tc
  RIGHT JOIN public.twilio_call_transitions AS tct ON tc.twilio_call_sid = tct.twilio_call_sid
  WHERE tc.widget_id = CALL.widget_id
    AND tc."from" = CALL."from"
  ORDER BY tc.id DESC,
           tct.sequence_number DESC LIMIT 1;
$$ IMMUTABLE;

GRANT USAGE ON SCHEMA public TO admin, common_user, anonymous;

GRANT SELECT, INSERT, UPDATE, DELETE ON public.twilio_calls
TO admin, common_user, anonymous;

GRANT SELECT, UPDATE, INSERT, DELETE ON public.twilio_call_transitions
TO admin, common_user, anonymous;

GRANT USAGE ON SEQUENCE twilio_calls_id_seq TO admin, common_user, anonymous;
}
  end

  def down
    execute %Q{
REVOKE USAGE ON SEQUENCE twilio_calls_id_seq FROM admin, common_user, anonymous;

REVOKE SELECT, UPDATE, INSERT, DELETE ON public.twilio_call_transitions
FROM admin, common_user, anonymous;

REVOKE SELECT, INSERT, UPDATE, DELETE ON public.twilio_calls
FROM admin, common_user, anonymous;

REVOKE USAGE ON SCHEMA public FROM admin, common_user, anonymous;

DROP FUNCTION postgraphql.watch_twilio_call_transitions (CALL postgraphql.twilio_calls_arguments);

DROP TYPE postgraphql.watch_twilio_call_transition_record_set;

DROP TYPE postgraphql.twilio_calls_arguments;
}
  end
end
