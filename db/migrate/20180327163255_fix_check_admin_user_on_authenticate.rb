class FixCheckAdminUserOnAuthenticate < ActiveRecord::Migration
  def change
    execute %Q{
CREATE OR REPLACE FUNCTION postgraphql.authenticate(email text, password text)
 RETURNS postgraphql.jwt_token
 LANGUAGE plpgsql
 STRICT SECURITY DEFINER
AS $function$
  declare
    users public.users;
  begin
    select u.* into users
    from public.users as u
    where u.email = $1;

    if users.encrypted_password = crypt(password, users.encrypted_password) and users.admin = true then
      return ('admin', users.id)::postgraphql.jwt_token;
    elsif users.encrypted_password = crypt(password, users.encrypted_password) then
      return ('common_user', users.id)::postgraphql.jwt_token;
    else
      return null;
    end if;
  end;
$function$;
    }
  end
end
