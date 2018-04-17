class CreateWatchedCustomDomain < ActiveRecord::Migration
  def up
    execute %Q{
      CREATE OR REPLACE FUNCTION public.verify_custom_domain()
       RETURNS trigger
       LANGUAGE plpgsql
      AS $$
        BEGIN
          IF NEW.custom_domain is not null then
              CASE TG_OP
              WHEN 'INSERT' THEN
                  perform pg_notify('dns_channel', pgjwt.sign(json_build_object(
                      'action', 'verify_custom_domain',
                      'id', NEW.id,
                      'custom_domain', NEW.custom_domain
                      'pg_action', 'insert_custom_domain'
                      'sent_to_queuing', now(),
                      'jit', now()::timestamp
                  ), public.configuration('jwt_secret'), 'HS512'));
              WHEN 'UPDATE' THEN
                  perform pg_notify('dns_channel', pgjwt.sign(json_build_object(
                      'action', 'verify_custom_domain',
                      'id', NEW.id,
                      'custom_domain', NEW.custom_domain
                      'pg_action', 'update_custom_domain'
                      'sent_to_queuing', now(),
                      'jit', now()::timestamp
                  ), public.configuration('jwt_secret'), 'HS512'));
              ELSE
                  raise  'custom_domain_not_processed';
              END CASE;
          end if;

          IF (TG_OP == 'DELETE') THEN
              perform pg_notify('dns_channel', pgjwt.sign(json_build_object(
                  'action', 'verify_custom_domain',
                  'id', OLD.id,
                  'custom_domain', OLD.custom_domain
                  'pg_action', 'delete_custom_domain'
                  'sent_to_queuing', now(),
                  'jit', now()::timestamp
              ), public.configuration('jwt_secret'), 'HS512'));
          END IF;


          IF (TG_OP == 'INSERT', 'UPDATE') THEN
              return json_build_object(
                  'id', NEW.id,
                  'custom_domain', NEW.custom_domain,
                  'pg_action', 'insert_updated_custom_domain'
              );
          ELSE
              return json_build_object(
                  'id', OLD.id,
                  'custom_domain', OLD.custom_domain,
                  'pg_action', 'deleted_custom_domain'
              );
          END IF;
        END;
      $$;

      GRANT EXECUTE on FUNCTION microservices.verify_custom_domain() to postgraphql, admin, microservices;

      DROP TRIGGER IF EXISTS watched_custom_domain ON public.mobilizations;
      CREATE TRIGGER watched_custom_domain AFTER
          INSERT OR UPDATE OR DELETE ON public.mobilizations
          FOR EACH ROW
          EXECUTE PROCEDURE public.verify_custom_domain();
    }
  end

  def down
    execute %Q{
      DROP FUNCTION public.verify_custom_domain()
      DROP TRIGGER IF EXISTS watched_custom_domain ON public.mobilizations;
    }
  end
end
