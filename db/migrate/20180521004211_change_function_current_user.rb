class ChangeFunctionCurrentUser < ActiveRecord::Migration
  def up
    execute %Q{
create or replace view postgraphql.users as
select
    u.*,
    json_agg(json_build_object('id', t.id, 'name', t.name, 'label', t.label)) as tags
from public.users u
left join public.user_tags ut on ut.user_id = u.id
left join public.tags t on t.id = ut.tag_id
where u.id = current_setting('jwt.claims.user_id')::integer
group by u.id;

grant select on postgraphql.users to common_user;

drop function postgraphql.current_user();

CREATE OR REPLACE FUNCTION postgraphql."current_user"()
 RETURNS postgraphql.users
 LANGUAGE sql
 STABLE
AS $function$
  select *
  from postgraphql.users
  where id = current_setting('jwt.claims.user_id')::integer
$function$
}
  end

  def down
    execute %Q{
drop function postgraphql.current_user();

CREATE OR REPLACE FUNCTION postgraphql."current_user"()
 RETURNS users
 LANGUAGE sql
 STABLE
AS $function$
  select *
  from public.users
  where id = current_setting('jwt.claims.user_id')::integer
$function$

}
  end
end
