class ChangeFunctionNotifyToUsesPgjwt < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION public.notify(template_name text, relations json)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
    declare
        _community public.communities;
        _user public.users;
        _activist public.activists;
        _notification public.notifications;
        _notification_template public.notification_templates;
        _template_vars json;
    begin
        -- get community from relations
        select * from public.communities where id = ($2->>'community_id')::integer
            into _community;

        -- get user from relations
        select * from public.users where id = ($2->>'user_id')::integer
            into _user;

        -- get activist when set on relations
        select * from public.activists where id = ($2->>'activist_id')::integer
            into _activist;

        -- try get notification template from community
        select * from public.notification_templates nt
            where nt.community_id = ($2->>'community_id')::integer
                and nt.label = $1
            into _notification_template;

        -- if not found on community try get without community
        if _notification_template is null then
            select * from public.notification_templates nt
                where nt.label = $1
                into _notification_template;

            if _notification_template is null then
                raise 'invalid_notification_template';
            end if;
        end if;

        _template_vars := public.generate_notification_tags(relations);

        -- insert notification to database
        insert into notifications(activist_id, notification_template_id, template_vars, created_at, updated_at, user_id, email)
            values (_activist.id, _notification_template.id, _template_vars::jsonb, now(), now(), _user.id, $2->>'email')
        returning * into _notification;

        -- notify to notification_channels
        perform pg_notify('notifications_channel',pgjwt.sign(json_build_object(
            'action', 'deliver_notification',
            'id', _notification.id,
            'created_at', now(),
            'sent_to_queuing', now(),
            'jit', now()::timestamp
        ), public.configuration('jwt_secret'), 'HS512'));

        return json_build_object('id', _notification.id);
    end;
$function$

}
  end

  def down
    execute %Q{
drop function public.notify(template_name text, relations json);

}
  end
end
