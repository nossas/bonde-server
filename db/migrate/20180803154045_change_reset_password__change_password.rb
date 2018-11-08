class ChangeResetPasswordChangePassword < ActiveRecord::Migration
  def up
    execute <<-SQL
      drop function if exists postgraphql.reset_password_change_password(text,text);

      create type change_password_fields AS (
       user_first_name text,
       user_last_name text,
       token postgraphql.jwt_token
      );

      CREATE OR REPLACE FUNCTION postgraphql.reset_password_change_password(new_password text, token text)
       RETURNS change_password_fields
       LANGUAGE plpgsql
      AS $function$
          declare
              _password_fields change_password_fields%ROWTYPE;
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

              _password_fields.user_first_name = _user.first_name;
              _password_fields.user_last_name = _user.last_name;
              _password_fields.token = (
                  (case when _user.admin is true then 'admin' else 'common_user' end),
                  _user.id
              )::postgraphql.jwt_token;

              return _password_fields;
          end;
      $function$;

      grant execute on function postgraphql.reset_password_change_password(new_password text, token text) to anonymous;
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE FUNCTION postgraphql.reset_password_token_request(email text, locale text DEFAULT 'pt-BR'::text)
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
                  where id = _user.id
              returning * into _user;

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

      comment on function postgraphql.reset_password_token_request(email text, locale text) is
        E'@email text\n@locale text\nCreate token to user reset password and send notification about this.';

      grant execute on function postgraphql.reset_password_token_request(email text, locale text) to anonymous, postgraphql;
      grant usage on schema pgjwt to postgraphql, anonymous;
      grant execute on function public.configuration(text) to postgraphql, anonymous;
      grant select on public.configurations to postgraphql, anonymous;
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE FUNCTION postgraphql.request_reset_password_token(email text, locale text DEFAULT 'pt-BR'::text)
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
                  where id = _user.id
              returning * into _user;

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
      $function$
    SQL
  end
end
