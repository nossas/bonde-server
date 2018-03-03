class AddCreateCommunityToPostgraphql < ActiveRecord::Migration
  def up
    execute %Q{
      CREATE OR REPLACE FUNCTION postgraphql.create_community(data json)
        RETURNS json
        LANGUAGE plpgsql
      AS $function$
          declare
              _community public.communities;
          begin
              if current_role = 'anonymous' then
                  raise 'permission_denied';
              end if;

              if nullif(btrim($1->> 'name'::text), '') is null then
                  raise 'missing_community_name';
              end if;

              if nullif(btrim($1->> 'city'::text), '') is null then
                  raise 'missing_community_city';
              end if;

              insert into public.communities(name, city, created_at, updated_at)
                  values(
                      ($1->>'name')::text,
                      ($1->>'city')::text,
                      now(),
                      now()
                  ) returning * into _community;

              -- create user x community after create community
              insert into public.community_users(user_id, community_id, role, created_at, updated_at)
                  values(
                      postgraphql.current_user_id(),
                      _community.id,
                      1,
                      now(),
                      now()
                  );

              return row_to_json(_community);
          end;
      $function$
      ;

      grant execute on function postgraphql.create_community(json) to common_user, admin, anonymous;
      grant insert, select on public.communities to common_user, admin;
      grant usage on sequence communities_id_seq to common_user, admin;
    }
  end

  def down
    execute %Q{
      drop function postgraphql.create_community(data json);
    }
  end
end
