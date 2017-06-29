class AddCurrentUserRolesInteractionFunctions < ActiveRecord::Migration
  def up
    execute %Q{
grant select on public.community_users to common_user, admin;
create or replace function postgraphql.current_user_id() returns integer
    language sql as $$
        select id from postgraphql.current_user();
    $$;

create or replace function postgraphql.current_user_has_community_participation(com_id integer) returns boolean
    language sql as $$
        select exists(
            select true from public.community_users cu
                where cu.user_id = postgraphql.current_user_id()
                and cu.community_id = com_id
        );
    $$;

create or replace function postgraphql.current_user_has_community_participation(com_id integer, role_ids integer[]) returns boolean
    language sql as $$
        select exists(
            select true from public.community_users cu
                where cu.user_id = postgraphql.current_user_id()
                and cu.community_id = com_id
                and cu.role = ANY(role_ids)
        );
    $$;
}
  end

  def down
    execute %Q{
drop function postgraphql.current_user_id();
drop function postgraphql.current_user_has_community_participation(com_id integer);
drop function postgraphql.current_user_has_community_participation(com_id integer, role_ids integer[]);
}
  end
end
