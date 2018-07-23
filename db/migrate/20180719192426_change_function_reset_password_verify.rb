class ChangeFunctionResetPasswordVerify < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION postgraphql.reset_password_token_verify(token text)
       RETURNS json
       LANGUAGE plpgsql stable
      AS $function$
                declare
                    _jwt json;
                    _user public.users;
                begin

                    if (select valid from pgjwt.verify(token, public.configuration('jwt_secret'), 'HS512')) is false then
                        raise 'invalid_token';
                    end if;

                    select payload
                        from pgjwt.verify(token, public.configuration('jwt_secret'), 'HS512')
                    into _jwt;

                    if to_date(_jwt->>'expirated_at', 'YYYY MM DD') <= now()::date then
                        raise 'invalid_token';
                    end if;

                    select * from public.users u where u.id = (_jwt->>'id')::int and u.reset_password_token = token into _user;
                    if _user is null then
                        raise 'invalid_token';
                    end if;

                    return _jwt;
                end;
            $function$
      ;
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE FUNCTION postgraphql.reset_password_token_verify(token text)
       RETURNS json
       LANGUAGE plpgsql
      AS $function$
                declare
                    _jwt json;
                    _user public.users;
                begin

                    if (select valid from pgjwt.verify(token, public.configuration('jwt_secret'), 'HS512')) is false then
                        raise 'invalid_token';
                    end if;

                    select payload
                        from pgjwt.verify(token, public.configuration('jwt_secret'), 'HS512')
                    into _jwt;

                    if to_date(_jwt->>'expirated_at', 'YYYY MM DD') <= now()::date then
                        raise 'invalid_token';
                    end if;

                    select * from public.users u where u.id = (_jwt->>'id')::int and u.reset_password_token = token into _user;
                    if _user is null then
                        raise 'invalid_token';
                    end if;

                    return _jwt;
                end;
            $function$
      ;
    SQL
  end
end
