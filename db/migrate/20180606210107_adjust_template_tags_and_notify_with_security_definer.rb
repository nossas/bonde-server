class AdjustTemplateTagsAndNotifyWithSecurityDefiner < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION public.notify(template_name text, relations json)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
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
$function$;



CREATE OR REPLACE FUNCTION public.generate_notification_tags(relations json)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
        declare
            _subscription public.subscriptions;
            _donation public.donations;
            _last_subscription_payment public.donations;
            _activist public.activists;
            _community public.communities;
            _mobilization public.mobilizations;
            _user public.users;
            _result json;
        begin
            -- get subscription when json->>'subscription_id' is present
            select * from public.subscriptions where id = ($1->>'subscription_id')::integer
                into _subscription;

            -- get donation when json->>'donation_id' is present
            select * from public.donations where id = ($1->>'donation_id')::integer
                into _donation;

            -- get last subscription donation when json ->> 'subscription_id' is present
            select * from public.donations where local_subscription_id = _subscription.id
                order by created_at desc limit 1 into _last_subscription_payment;

            -- get activist when json ->> 'activist_id' is present or subscription/donation is found
            select * from public.activists where id = coalesce(coalesce(($1->>'activist_id')::integer, _subscription.activist_id), _donation.activist_id)
                into _activist;

            -- get community when json->>'community_id' is present or subscription/donation is found
            select * from public.communities where id = coalesce(coalesce(($1->>'community_id')::integer, _subscription.community_id), _donation.cached_community_id)
                into _community;
                
            -- get user when json->>'user_id' is present
            select * from public.users where id = ($1->>'user_id')::integer 
                into _user;

            -- get mobilization from subscription/donation widget when block is defined
            select * from mobilizations m
                join blocks b on b.mobilization_id = m.id
                join widgets w on w.block_id = b.id
                where w.id = coalesce(_subscription.widget_id, _donation.widget_id)
                into _mobilization;


            -- build and return template tags json after collect all data
            _result := json_build_object(
                'subscription_id', _subscription.id,
                'payment_method', coalesce(_subscription.payment_method, _donation.payment_method),
                'donation_id', _donation.id,
                'widget_id', _donation.widget_id,
                'mobilization_id', _mobilization.id,
                'mobilization_name', _mobilization.name,
                'boleto_expiration_date', (_donation.gateway_data ->> 'boleto_expiration_date'),
                'boleto_barcode', (_donation.gateway_data ->> 'boleto_barcode'),
                'boleto_url', (_donation.gateway_data ->> 'boleto_url'),
                'manage_url', (
                    case when _subscription.id is not null then
                        'https://app.bonde.org/subscriptions/'||_subscription.id||'/edit?token='||_subscription.token
                    else null end
                ),
                'amount', (coalesce(_subscription.amount, _donation.amount) / 100),
                'user', json_build_object(
                    'first_name', _user.first_name,
                    'last_name', _user.last_name
                ),
                'customer', json_build_object(
                    'name', _activist.name,
                    'first_name', _activist.first_name,
                    'last_name', _activist.last_name
                ),
                'community', json_build_object(
                    'id', _community.id,
                    'name', _community.name,
                    'image', _community.image
                ),
                'last_donation', json_build_object(
                    'payment_method', _last_subscription_payment.payment_method,
                    'widget_id', _last_subscription_payment.widget_id,
                    'mobilization_id', _mobilization.id,
                    'mobilization_name', _mobilization.name,
                    'boleto_expiration_date', (_last_subscription_payment.gateway_data ->> 'boleto_expiration_date'),
                    'boleto_barcode', (_last_subscription_payment.gateway_data ->> 'boleto_barcode'),
                    'boleto_url', (_last_subscription_payment.gateway_data ->> 'boleto_url')
                )
            );
            
            return _result;
        end;
    $function$;
}
  end
  

  def down
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
        raise notice 'notification %', _notification;

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
$function$;



CREATE OR REPLACE FUNCTION public.generate_notification_tags(relations json)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
        declare
            _subscription public.subscriptions;
            _donation public.donations;
            _last_subscription_payment public.donations;
            _activist public.activists;
            _community public.communities;
            _mobilization public.mobilizations;
            _user public.users;
            _result json;
        begin
            -- get subscription when json->>'subscription_id' is present
            select * from public.subscriptions where id = ($1->>'subscription_id')::integer
                into _subscription;

            -- get donation when json->>'donation_id' is present
            select * from public.donations where id = ($1->>'donation_id')::integer
                into _donation;

            -- get last subscription donation when json ->> 'subscription_id' is present
            select * from public.donations where local_subscription_id = _subscription.id
                order by created_at desc limit 1 into _last_subscription_payment;

            -- get activist when json ->> 'activist_id' is present or subscription/donation is found
            select * from public.activists where id = coalesce(coalesce(($1->>'activist_id')::integer, _subscription.activist_id), _donation.activist_id)
                into _activist;

            -- get community when json->>'community_id' is present or subscription/donation is found
            select * from public.communities where id = coalesce(coalesce(($1->>'community_id')::integer, _subscription.community_id), _donation.cached_community_id)
                into _community;
                
            -- get mobilization from subscription/donation widget when block is defined
            select * from mobilizations m
                join blocks b on b.mobilization_id = m.id
                join widgets w on w.block_id = b.id
                where w.id = coalesce(_subscription.widget_id, _donation.widget_id)
                into _mobilization;


            -- build and return template tags json after collect all data
            _result := json_build_object(
                'subscription_id', _subscription.id,
                'payment_method', coalesce(_subscription.payment_method, _donation.payment_method),
                'donation_id', _donation.id,
                'widget_id', _donation.widget_id,
                'mobilization_id', _mobilization.id,
                'mobilization_name', _mobilization.name,
                'boleto_expiration_date', (_donation.gateway_data ->> 'boleto_expiration_date'),
                'boleto_barcode', (_donation.gateway_data ->> 'boleto_barcode'),
                'boleto_url', (_donation.gateway_data ->> 'boleto_url'),
                'manage_url', (
                    case when _subscription.id is not null then
                        'https://app.bonde.org/subscriptions/'||_subscription.id||'/edit?token='||_subscription.token
                    else null end
                ),
                'amount', (coalesce(_subscription.amount, _donation.amount) / 100),
                'customer', json_build_object(
                    'name', _activist.name,
                    'first_name', _activist.first_name,
                    'last_name', _activist.last_name
                ),
                'community', json_build_object(
                    'id', _community.id,
                    'name', _community.name,
                    'image', _community.image
                ),
                'last_donation', json_build_object(
                    'payment_method', _last_subscription_payment.payment_method,
                    'widget_id', _last_subscription_payment.widget_id,
                    'mobilization_id', _mobilization.id,
                    'mobilization_name', _mobilization.name,
                    'boleto_expiration_date', (_last_subscription_payment.gateway_data ->> 'boleto_expiration_date'),
                    'boleto_barcode', (_last_subscription_payment.gateway_data ->> 'boleto_barcode'),
                    'boleto_url', (_last_subscription_payment.gateway_data ->> 'boleto_url')
                )
            );
            
            return _result;
        end;
    $function$;

}
  end
end
