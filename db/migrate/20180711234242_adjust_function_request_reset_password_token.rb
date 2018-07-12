class AdjustFunctionRequestResetPasswordToken < ActiveRecord::Migration
  def up
    execute %Q{
drop function if EXISTS postgraphql.request_reset_password_token(data json);

CREATE OR REPLACE FUNCTION postgraphql.request_reset_password_token(email text, locale text default 'pt-BR')
 RETURNS void
 LANGUAGE plpgsql
AS $function$
    declare
        _user public.users;
        _notification_template_id integer;
        _locale text;
        _notification public.notifications;
    begin
        _locale := coalesce(locale, 'pt-BR');

        -- find user by email
        select * from public.users u where u.email = $1
            into _user;

        if _user.id is null then
            raise 'user_not_found';
        end if;

        -- generate new reset token
        update public.users
            set reset_password_token = pgjwt.sign(json_build_object(
              'id', _user.id,
              'expirated_at', now() + interval '48 hours'
          ), public.configuration('jwt_secret'), 'HS512')
            where id = _user.id;

        -- TODO think other utilities this snippet
        -- get notification template id for user locale
        select nt.id from public.notification_templates nt where label = 'reset_password_instructions'
            and nt.locale = _locale limit 1
            into _notification_template_id;

        -- fallback on default locale when locale from user not found
        if _notification_template_id is null then
            select nt.id from public.notification_templates nt where label = 'reset_password_instructions'
                and nt.locale = 'pt-BR'
                into _notification_template_id;

            if _notification_template_id is null then
                raise 'invalid_notification_template';
            end if;
        end if;

        -- notify user about reset password instructions
        insert into public.notifications(user_id, notification_template_id, template_vars, created_at, updated_at)
            values (_user.id, _notification_template_id, json_build_object(
                'user', json_build_object(
                    'id', _user.id,
                    'uid', _user.uid,
                    'email', _user.email,
                    'first_name', _user.first_name,
                    'last_name', _user.last_name,
                    'reset_password_token', _user.reset_password_token)
            ), now(), now()) returning * into _notification;

        -- notify to notification_channels
        perform pg_notify('notifications_channel',pgjwt.sign(json_build_object(
            'action', 'deliver_notification',
            'id', _notification.id,
            'created_at', now(),
            'sent_to_queuing', now(),
            'jit', now()::timestamp
        ), public.configuration('jwt_secret'), 'HS512'));
    end;
$function$;

comment on function postgraphql.request_reset_password_token(email text, locale text) is 
  E'@email text\n@locale text\nCreate token to user reset password and send notification about this.';

grant execute on function postgraphql.request_reset_password_token(email text, locale text) to anonymous, postgraphql;
grant usage on schema pgjwt to postgraphql, anonymous;
grant execute on function public.configuration(text) to postgraphql, anonymous;
grant select on public.configurations to postgraphql, anonymous;

}
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION postgraphql.request_reset_password_token(data json)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
    declare
        _user public.users;
        _notification_template_id integer;
        _locale text;
    begin
        _locale := coalesce($1->>'locale'::text, 'pt-BR');

        -- find user by email
        select * from users u where u.email = ($1->>'email'::text)::email
            into _user;

        if _user.id is null then
            raise 'user_not_found';
        end if;

        -- generate new reset token
        update public.users
            set reset_password_token = uuid_generate_v4()
            where id = _user.id;

        -- get notification template id for user locale
        select id from public.notification_templates where label = 'reset_password_instructions'
            and locale = _locale limit 1
            into _notification_template_id;

        -- fallback on default locale when locale from user not found
        if _notification_template_id is null then
            select id from public.notification_templates where label = 'reset_password_instructions'
                and locale = 'pt-BR'
                into _notification_template_id;

            if _notification_template_id is null then
                raise 'invalid_template';
            end if;
        end if;
        -- notify user about reset password instructions
        insert into public.notifications(user_id, notification_template_id, template_vars, created_at, updated_at)
            values (_user.id, _notification_template_id, json_build_object(
                'user', json_build_object(
                    'id', _user.id,
                    'uid', _user.uid,
                    'email', _user.email,
                    'first_name', _user.first_name,
                    'last_name', _user.last_name,
                    'reset_password_token', _user.reset_password_token)
            ), now(), now());
    end;
$function$
}
  end
end
