class ResetPasswordChangePassword < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION postgraphql.reset_password_change_password(new_password text, token text)
      returns postgraphql.jwt_token
      language plpgsql
      AS $function$
          declare
              _jwt json;
              _user public.users;
          begin

              select postgraphql.reset_password_token_verify(token) into _jwt;

              select * from public.users where id = (_jwt->>'id')::int into _user;

              if nullif(new_password, '') is null then
                  raise 'missing_password';
              end if;

              if length(new_password) < 6 then
                  raise 'password_lt_six_chars';
              end if;

              update public.users
                  set encrypted_password = public.crypt(new_password, public.gen_salt('bf', 9)), reset_password_token = null
              where id = _user.id;

              return (
                  (case when _user.admin is true then 'admin' else 'common_user' end),
                  _user.id
              )::postgraphql.jwt_token;
          end;
      $function$;
      grant execute on function postgraphql.reset_password_change_password(new_password text, token text) to anonymous;
    SQL
  end

  def down
    execute <<-SQL
      drop function postgraphql.reset_password_change_password(new_password text, token text);
    SQL
  end
end
