class ChangeFunctionCreateCommunityToGenerateJwt < ActiveRecord::Migration
  def up
    execute %Q{
      CREATE OR REPLACE FUNCTION microservices.create_community_dns(data json)
       RETURNS json
       LANGUAGE plpgsql
      AS $function$
        declare
          _community public.communities;
          _dns_hosted_zone public.dns_hosted_zones;
          _dns public.dns_hosted_zones;
        begin
          -- to execute function in api-v1
          -- if current_role <> 'microservices' then
          --     raise 'permission_denied';
          -- end if;

          select * from public.communities c where c.id = ($1->>'community_id')::integer
          into _community;

          if _community is null then
              raise 'community_not_found';
          end if;

          select *
              from public.dns_hosted_zones
          where community_id = _community.id and domain_name = $1->>'domain_name'
          into _dns;

          if _dns is null then
              insert into public.dns_hosted_zones(community_id, domain_name, comment, created_at, updated_at, ns_ok)
              values (
                  _community.id, $1->>'domain_name', $1->>'comment', now(), now(), false
              )
              returning * into _dns_hosted_zone;
          else
              select *
                  from public.dns_hosted_zones
              where community_id = _community.id and domain_name = $1->>'domain_name'
              into _dns_hosted_zone;
          end if;

          -- after create dns_hosted_zone perform route53
          perform pg_notify('dns_channel',pgjwt.sign(json_build_object(
              'action', 'create_hosted_zone',
              'id', _dns_hosted_zone.id,
              'domain', _dns_hosted_zone.domain_name,
              'created_at', _dns_hosted_zone.created_at,
              'sent_to_queuing', now(),
              'jit', now()::timestamp
          ), public.configuration('jwt_secret'), 'HS512'));

          return json_build_object(
              'id', _dns_hosted_zone.id,
              'community_id', _dns_hosted_zone.community_id,
              'domain_name', _dns_hosted_zone.domain_name,
              'comment', _dns_hosted_zone.comment,
              'ns_ok', _dns_hosted_zone.ns_ok
          );
        end;
      $function$;
    }
  end

  def down
    execute %Q{
      drop function microservices.create_community_dns(data json)
    }
  end
end
