class AddInvitationOnRegisterUser < ActiveRecord::Migration
  def change
    execute %Q{
-- Validation invite to register user in next step
drop function if exists postgraphql.check_invitation(invitation_code text);

create or replace function postgraphql.check_invitation(invitation_code text)
  returns setof public.invitations
  language sql
  immutable
as $function$
  select * from public.invitations where code=invitation_code
$function$;
-- check this grant
grant select on public.invitations to anonymous, common_user, admin, postgraphql;

-- Register user with possibility on invite user to community

drop function if exists postgraphql.register(data json);

CREATE OR REPLACE FUNCTION postgraphql.register(data json)
 RETURNS postgraphql.jwt_token
 LANGUAGE plpgsql
AS $function$
    declare
        _user public.users;
        _invitation public.invitations;
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
        
        -- related created user with community by invitation_code
        if nullif(($1->> 'invitation_code')::text, '') is not null then
          select * from public.invitations where code = ($1->>'invitation_code'::text) into _invitation;
          insert into public.community_users(user_id, community_id, role, created_at, updated_at) values (
            _user.id,
            _invitation.community_id,
            _invitation.role,
            now(),
            now()
          );
        end if;
        
        return ('common_user', _user.id)::postgraphql.jwt_token;
    end;
$function$;

grant select, insert on public.community_users to anonymous, common_user, admin, postgraphql;
grant usage on community_users_id_seq to anonymous, common_user, admin, postgraphql;
    }
  end
end
