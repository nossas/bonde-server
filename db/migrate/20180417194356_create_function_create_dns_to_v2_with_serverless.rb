class CreateFunctionCreateDnsToV2WithServerless < ActiveRecord::Migration
  def up
    execute %Q{
      CREATE OR REPLACE FUNCTION postgraphql.create_dns_record(data json)
       RETURNS json
       LANGUAGE plpgsql
      AS $function$
        declare
          _dns_hosted_zone public.dns_hosted_zones;
          _dns_record public.dns_records;
        begin
          -- to execute function in api-v1
          -- if current_role <> 'microservices' then
          --     raise 'permission_denied';
          -- end if;

          select * from public.dns_hosted_zones d where d.id = ($1->>'dns_hosted_zone_id')::integer
          into _dns_hosted_zone;

          if _dns_hosted_zone is null then
              raise 'dns_hosted_zone_not_found';
          end if;

          select *
              from public.dns_records
          where name = $1->>'name' and record_type = $1->>'record_type'
          into _dns_record;

          if _dns_record is null then
              insert into public.dns_records(dns_hosted_zone_id, name, record_type, value, ttl, created_at, updated_at, comment)
              values (
                  _dns_hosted_zone.id, $1->>'name', $1->>'record_type', $1->>'value', $1->>'ttl', now(), now(),  $1->>'comment'
              )
              returning * into _dns_record;

              -- after create dns_record perform route53
              perform pg_notify('dns_channel', pgjwt.sign(json_build_object(
                  'action', 'create_dns_record',
                  'id', _dns_record.id,
                  'created_at', _dns_record.created_at,
                  'sent_to_queuing', now(),
                  'jit', now()::timestamp
              ), public.configuration('jwt_secret'), 'HS512'));

              return json_build_object(
                  'id', _dns_record.id,
                  'dns_hosted_zone_id', _dns_record.dns_hosted_zone_id,
                  'name', _dns_record.name,
                  'comment', _dns_record.comment
              );
          else
              raise 'dns_record_already_registered';
          end if;
        end;
      $function$;

      GRANT EXECUTE on FUNCTION postgraphql.create_dns_record(data json) TO postgraphql;
      GRANT SELECT, INSERT ON public.dns_records TO admin, microservices, postgraphql;
      GRANT usage ON SEQUENCE dns_records_id_seq TO postgraphql, microservices, admin;
    }
  end

  def down
    execute %Q{
    DROP FUNCTION postgraphql.create_dns_record(data json);
    }
  end
end
