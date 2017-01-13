class AddTotalActionsToAggActivists < ActiveRecord::Migration
  def up
    execute %Q{
drop view public.agg_activists;
create or replace view public.agg_activists as
    select
        com.id as community_id,
        a.id as activist_id,
        a.email,
        a.name as name,
        (btrim(a.phone, '{}')::hstore->'ddd')::text||(btrim(a.phone, '{}')::hstore->'number')::text  as phone,
        count(distinct fe.id) as total_form_entries,
        count(distinct d.id) as total_donations,
        count(distinct ap.id) as total_pressures,
        (count(distinct fe.id) + count(distinct d.id) + count(distinct ap.id)) as total_actions,
        last_donation.transaction_status as last_donation_status,
        last_donation.amount/100 as last_donation_amount,
        last_donation.subscription as last_donation_is_subscription
    from communities com
        left join mobilizations m on m.community_id = com.id
        left join blocks b on b.mobilization_id = m.id
        left join widgets w on w.block_id = b.id

        left join form_entries fe on fe.widget_id = w.id
        left join donations d on d.widget_id = w.id
            and d.transaction_id is not null and d.transaction_status is not null
        left join activist_pressures ap on ap.widget_id = w.id

        left join activists a on a.id = fe.activist_id
            or a.id = d.activist_id
            or a.id = ap.activist_id

        left join lateral (
            select
                *
            from donations d2
            where
                d2.activist_id = a.id
                and d2.transaction_id is not null
                and d2.transaction_status is not null
            order by id desc limit 1
        ) as last_donation on true
    where a.id is not null
    group by com.id, a.email, a.id, last_donation.transaction_status,
    last_donation.amount, last_donation.subscription;
}

  end

  def down
    execute %Q{
drop view public.agg_activists;
create or replace view public.agg_activists as
    select
        com.id as community_id,
        a.id as activist_id,
        a.email,
        a.name as name,
        (btrim(a.phone, '{}')::hstore->'ddd')::text||(btrim(a.phone, '{}')::hstore->'number')::text  as phone,
        count(distinct fe.id) as total_form_entries,
        count(distinct d.id) as total_donations,
        count(distinct ap.id) as total_pressures,
        last_donation.transaction_status as last_donation_status,
        last_donation.amount/100 as last_donation_amount,
        last_donation.subscription as last_donation_is_subscription
    from communities com
        left join mobilizations m on m.community_id = com.id
        left join blocks b on b.mobilization_id = m.id
        left join widgets w on w.block_id = b.id

        left join form_entries fe on fe.widget_id = w.id
        left join donations d on d.widget_id = w.id
            and d.transaction_id is not null and d.transaction_status is not null
        left join activist_pressures ap on ap.widget_id = w.id

        left join activists a on a.id = fe.activist_id
            or a.id = d.activist_id
            or a.id = ap.activist_id

        left join lateral (
            select
                *
            from donations d2
            where
                d2.activist_id = a.id
                and d2.transaction_id is not null
                and d2.transaction_status is not null
            order by id desc limit 1
        ) as last_donation on true
    where a.id is not null
    group by com.id, a.email, a.id, last_donation.transaction_status,
    last_donation.amount, last_donation.subscription;
}
    
  end
end
