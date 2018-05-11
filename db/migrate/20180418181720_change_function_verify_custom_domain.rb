class ChangeFunctionVerifyCustomDomain < ActiveRecord::Migration
  def change
  end

  def up
    execute %Q{
      CREATE OR REPLACE FUNCTION public.verify_custom_domain()
       RETURNS trigger
       LANGUAGE plpgsql
      AS $$
        BEGIN
          CASE TG_OP
          WHEN 'INSERT' THEN
              IF NEW.custom_domain IS NOT NULL THEN
                  perform pg_notify('dns_channel', pgjwt.sign(json_build_object(
                      'action', 'verify_custom_domain',
                      'id', NEW.id,
                      'custom_domain', NEW.custom_domain,
                      'pg_action', 'insert_custom_domain',
                      'sent_to_queuing', now(),
                      'jit', now()::timestamp
                  ), public.configuration('jwt_secret'), 'HS512'));
              END IF;
              RETURN NEW;

          WHEN 'UPDATE' THEN
              IF NEW.custom_domain IS NOT NULL THEN
                  perform pg_notify('dns_channel', pgjwt.sign(json_build_object(
                      'action', 'verify_custom_domain',
                      'id', NEW.id,
                      'custom_domain', NEW.custom_domain,
                      'pg_action', 'update_custom_domain',
                      'sent_to_queuing', now(),
                      'jit', now()::timestamp
                  ), public.configuration('jwt_secret'), 'HS512'));
              END IF;
              RETURN NEW;

          WHEN 'DELETE' THEN
              perform pg_notify('dns_channel', pgjwt.sign(json_build_object(
                  'action', 'verify_custom_domain',
                  'id', OLD.id,
                  'custom_domain', OLD.custom_domain,
                  'pg_action', 'delete_custom_domain',
                  'sent_to_queuing', now(),
                  'jit', now()::timestamp
              ), public.configuration('jwt_secret'), 'HS512'));

              RETURN OLD;
          ELSE
              raise  'custom_domain_not_processed';
          END CASE;
        END;
      $$;
    }
  end

  def down
    execute %Q{
      drop funciton public.verify_custom_domain();
      DROP TRIGGER IF EXISTS watched_custom_domain ON public.mobilizations;
    }
  end
end
