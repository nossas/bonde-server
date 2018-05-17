class AddBuildTemplateTagsToNotifications < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function public.generate_notification_tags(relations json)
    returns json language plpgsql as $$
        declare
            _subscription public.subscriptions;
            _donation public.donations;
            _last_subscription_payment public.donations;
            _activist public.activists;
            _community public.communities;
            _mobilization public.mobilizations;
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
            return json_build_object(
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
        end;
    $$;
}
  end

  def down
    execute %Q{
drop function public.generate_notification_tags(relations json);
}
  end
end
