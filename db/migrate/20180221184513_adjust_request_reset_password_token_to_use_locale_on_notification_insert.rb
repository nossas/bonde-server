class AdjustRequestResetPasswordTokenToUseLocaleOnNotificationInsert < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION postgraphql.request_reset_password_token(email email)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
    declare
        _user public.users;
        _notification_template_id integer;
    begin
        -- find user by email
        select * from users u where u.email = $1
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
            and locale = _user.locale limit 1
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
$function$;
}
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION postgraphql.request_reset_password_token(email email)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
    declare
        _user public.users;
        _notification_template_id integer;
    begin
        -- find user by email
        select * from users u where u.email = $1
            into _user;

        if _user.id is null then
            raise 'user_not_found';
        end if;

        -- generate new reset token
        update public.users
            set reset_password_token = uuid_generate_v4()
            where id = _user.id;
            
        -- notify user about request password change
        select id from public.notification_templates where label = 'reset_password_instructions'
            into _notification_template_id;
        if _notification_template_id is null then
            raise 'invalid_template';
        end if;
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
$function$;
}
  end
end
