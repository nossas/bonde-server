class AddChangePasswordFuncToPostgraphql < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function postgraphql.change_password(data json)
returns postgraphql.jwt_token language plpgsql as $$
    declare
        _user public.users;
    begin
        if nullif(($1->> 'password')::text, '') is null then
            raise 'missing_password';
        end if;

        if length(($1->>'password'::text)) < 6 then
            raise 'password_lt_six_chars';
        end if;

        if ($1->>'password'::text) <> ($1->>'password_confirmation'::text) then
            raise 'password_confirmation_not_match';
        end if;

        -- when user is anonymous should be have reset_password_token
        if current_role = 'anonymous' then
            if nullif(($1->>'reset_password_token')::text, '') is not null then
                select * from public.users 
                    where reset_password_token is not null
                        and ($1->>'reset_password_token')::text = reset_password_token
                    into _user;

                if _user.id is null then
                    raise 'invalid_reset_password_token';
                end if;
            else
                raise 'missing_reset_password_token';
            end if;
        else
        -- when user already logged (jwt) should not require reset_password_token
            select * from users where id = postgraphql.current_user_id()
                into _user;
        end if;
        
        update users
            set encrypted_password = public.crypt(($1->>'password')::text, public.gen_salt('bf', 9))
        where id = _user.id;
        
        return (
            (case when _user.admin is true then 'admin' else 'common_user' end), 
            _user.id
        )::postgraphql.jwt_token;        
    end;
$$;
grant execute on function postgraphql.change_password(data json) to common_user, admin, anonymous;
grant select, update on users to common_user, admin, anonymous;
}
  end

  def down
    execute %Q{
  drop function postgraphql.change_password(data json);
}
  end
end
