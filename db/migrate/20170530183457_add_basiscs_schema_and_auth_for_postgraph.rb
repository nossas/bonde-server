class AddBasiscsSchemaAndAuthForPostgraph < ActiveRecord::Migration
  def change
    execute %Q{
create schema postgraphql;

create extension if not exists "pgcrypto";

create type postgraphql.jwt_token as (
  role text,
  user_id integer
);

create function postgraphql.authenticate (
  email text,
  password text
) returns postgraphql.jwt_token as $$
  declare
    users public.users;
  begin
    select u.* into users
    from public.users as u
    where u.email = $1;

    if users.encrypted_password = crypt(password, users.encrypted_password) and users.admin = true then
      return ('admin', users.id)::postgraphql.jwt_token;
    elsif users.encrypted_password = crypt(password, users.encrypted_password) and users.admin = false then
      return ('common_user', users.id)::postgraphql.jwt_token;
    else
      return null;
    end if;
  end;
$$ language plpgsql strict security definer;

comment on function postgraphql.authenticate(text, text) is 'Creates a JWT token that will securely identify a user and give them certain permissions.';

create role postgraphql login password '3x4mpl3';
create role anonymous;
create role common_user;
create role admin;

grant common_user to admin;
grant admin to postgraphql;
grant anonymous to postgraphql;

grant usage on schema postgraphql to anonymous, common_user, admin;
}
  end
end
