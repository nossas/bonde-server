class AddCommunityParticipationsForCurrentUser < ActiveRecord::Migration
  def up
    execute %Q{
create or replace view postgraphql.community_user_roles as
    select
        *
    from public.community_users cu
        where cu.user_id = postgraphql.current_user_id();
grant select on postgraphql.community_user_roles to common_user, admin;

create or replace view postgraphql.participations as
    select ap.*
        from activist_participations ap
        where community_id in(select community_id from postgraphql.community_user_roles);

grant select on public.activist_participations to common_user, admin;
grant select on postgraphql.participations to common_user, admin;
}
  end

  def down
    execute %Q{drop view postgraphql.community_user_roles;}
  end
end
