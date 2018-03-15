class AddCreateCommunityDnsPostgraphql < ActiveRecord::Migration
  def up
    execute %Q{
      CREATE OR REPLACE FUNCTION microservices.create_community_dns(data json)
      RETURNS json
      LANGUAGE plpgsql
      AS $function$
        declare
          _community public.communities;
          _dns_hosted_zone public.dns_hosted_zones;
        begin
          if current_role <> 'microservices' then
              raise 'permission_denied';
          end if;

          select * from public.communities c where c.id = ($1->>'community_id')::integer
          into _community;

          if _community is null then
              raise 'community_not_found';
          end if;

          insert into public.dns_hosted_zones(community_id, domain_name, comment, created_at, updated_at, ns_ok)
              values (
                  _community.id, $1->>'domain_name', $1->>'comment', now(), now(), false
              )
          returning * into _dns_hosted_zone;

          -- after create dns_hosted_zone perform route53
          perform pg_notify('route53_channel', json_build_object(
              'action', 'create_hosted_zone',
              'id', _dns_hosted_zone.id,
              'created_at', _dns_hosted_zone.created_at
          )::text);

          return json_build_object(
              'id', _dns_hosted_zone.id,
              'community_id', _dns_hosted_zone.community_id,
              'domain_name', _dns_hosted_zone.domain_name,
              'comment', _dns_hosted_zone.comment,
              'ns_ok', _dns_hosted_zone.ns_ok
          );
        end;
      $function$;

      GRANT USAGE ON SCHEMA microservices to postgres;
      GRANT EXECUTE on FUNCTION microservices.create_community_dns(data json) to microservices;
      GRANT INSERT, SELECT on public.dns_hosted_zones to microservices;
      GRANT USAGE ON SEQUENCE dns_hosted_zones_id_seq to microservices;
      GRANT SELECT ON TABLE public.communities to microservices;
        }
  end

  def down
    execute %Q{
      drop function microservices.create_community_dns(data json);
    }
  end
end
