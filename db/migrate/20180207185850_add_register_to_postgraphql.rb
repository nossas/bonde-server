class AddRegisterToPostgraphql < ActiveRecord::Migration
  def up
    execute %Q{
grant usage on sequence users_id_seq to anonymous;
grant insert, select on public.users to anonymous;
create or replace function postgraphql.register(data json)
    returns postgraphql.jwt_token language plpgsql as $$
    declare
        _user public.users;
    begin
        if current_role <> 'anonymous' then
            raise 'user_already_logged';
        end if;
        -- check if first_name, email and password are present
        if nullif(btrim($1->> 'first_name'::text), '') is null then
            raise 'missing_first_name';
        end if;
    
        if nullif(btrim($1->> 'email'::text), '') is null then
            raise 'missing_email';
        end if;
    
        if nullif(($1->> 'password')::text, '') is null then
            raise 'missing_password';
        end if;
        
        if length(($1->>'password'::text)) < 6 then
            raise 'password_lt_six_chars';
        end if;
        
        insert into public.users(uid, provider, email, encrypted_password, first_name, last_name)
            values (
                ($1->>'email')::email, 
                'email', 
                ($1->>'email')::email, 
                crypt($1->>'password'::text, gen_salt('bf', 9)),
                ($1->>'first_name')::text,
                ($1->>'last_name')::text
            ) returning * into _user;
        
        return ('common_user', _user.id)::postgraphql.jwt_token;
    end;
$$;
  grant execute on function postgraphql.register(json) to anonymous;
}
  end

  def down
    execute %Q{
    drop function postgraphql.register(data json)
}
  end
end
