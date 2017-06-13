class AddCurrentUserToDb < ActiveRecord::Migration
  def change
    execute %Q{
grant select on public.users to common_user;

create or replace function postgraphql.current_user() returns public.users as $$
  select *
  from public.users
  where id = current_setting('jwt.claims.user_id')::integer
$$ language sql stable;

comment on function postgraphql.current_user() is 'Gets the user who was indentified by our JWT.';
}
  end
end
