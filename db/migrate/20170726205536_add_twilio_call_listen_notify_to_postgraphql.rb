class AddTwilioCallListenNotifyToPostgraphql < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION notify_twilio_call_trigger()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
  DECLARE
    BEGIN perform pg_notify('twilio_call_created', row_to_json(NEW)::text);
    RETURN NEW;
  END;
$$;

CREATE TRIGGER watched_twilio_call_trigger AFTER
INSERT ON public.twilio_calls
FOR EACH ROW EXECUTE PROCEDURE notify_twilio_call_trigger();
}
  end

  def down
    execute %Q{
DROP TRIGGER watched_twilio_call_trigger ON public.twilio_calls;

DROP FUNCTION notify_twilio_call_trigger();
}
  end
end
