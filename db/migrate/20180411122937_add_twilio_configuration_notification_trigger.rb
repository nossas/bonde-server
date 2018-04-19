class AddTwilioConfigurationNotificationTrigger < ActiveRecord::Migration
  def up
    execute %Q{
      CREATE OR REPLACE FUNCTION public.notify_create_twilio_configuration_trigger()
      RETURNS TRIGGER LANGUAGE plpgsql AS $$
        BEGIN
          IF (TG_OP = 'INSERT') THEN
            perform pg_notify('twilio_configuration_created', row_to_json(NEW)::text);
          END IF;

          IF (TG_OP = 'UPDATE') THEN
            perform pg_notify('twilio_configuration_updated', row_to_json(NEW)::text);
          END IF;

          RETURN NEW;
        END;
      $$;

      CREATE TRIGGER watched_create_twilio_configuration_trigger AFTER
      INSERT OR UPDATE ON public.twilio_configurations
      FOR EACH ROW EXECUTE PROCEDURE public.notify_create_twilio_configuration_trigger();
    }
  end

  def down
    execute %Q{
      DROP TRIGGER watched_create_twilio_configuration_trigger ON public.twilio_configurations;
      DROP FUNCTION public.notify_create_twilio_configuration_trigger();
    }
  end
end
