# coding: utf-8
class AddSubscriptionStatusToDonationReport < ActiveRecord::Migration
  def up
    execute %Q{
create or replace view public.donation_reports as
select
    m.id as mobilization_id,
    w.id as widget_id,
    c.id as community_id,
    d.id,
    d.transaction_id,
    d.transaction_status as "status",
    to_char(d.created_at, 'dd/mm/YYYY') as "data",
    coalesce(d.customer -> 'name', a.name) as "nome",
    d.email as "email",
    coalesce(customer_phone.number, activist_phone.number) as "telefone",
    d.payment_method as "cartao/boleto",
    (case when d.subscription then 'Sim' else 'Não' end) as "recorrente",
    (d.amount / 100.0)::double precision as "valor",
    pd.value_without_fee as "valor garantido",
    to_char((d.gateway_data ->> 'boleto_expiration_date')::timestamp, 'dd/mm/YYYY') as "data vencimento boleto",
    recurrency_donation.count as "recorrencia da doacao",
    recurrency_activist.count as "recorrencia do ativista",
    gs.gateway_data ->> 'status' as subscription_status
    
from donations d
join widgets w on w.id = d.widget_id
join blocks b on b.id = w.block_id
join mobilizations m on m.id = b.mobilization_id
join communities c on c.id = m.community_id
left join gateway_subscriptions gs on gs.subscription_id = d.subscription_id::integer
left join payable_details pd on pd.donation_id = d.id
left join activists a on a.id = d.activist_id
left join lateral (
    select
        (btrim(btrim(d.customer->'phone'), '{}')::hstore -> 'ddd')||(btrim(btrim(d.customer->'phone'), '{}')::hstore -> 'number') as number
) as customer_phone on true
left join lateral (
    select
        (((btrim((a.phone)::text, '{}'::text))::hstore -> 'ddd'::text) || ((btrim((a.phone)::text, '{}'::text))::hstore -> 'number'::text)) as number
) as activist_phone on true
left join lateral (
    select
        count(1) 
            from donations d2 where 
            d2.subscription_id = d.subscription_id
) as recurrency_donation on true
left join lateral (
    select
        count(1) 
            from donations d2 where 
            d2.activist_id = d.activist_id
            and d.activist_id is not null
) as recurrency_activist on true;
}
  end

  def down
    execute %Q{
DROP VIEW "donation_reports";
CREATE OR REPLACE VIEW "donation_reports" AS 
 SELECT m.id AS mobilization_id,
    w.id AS widget_id,
    c.id AS community_id,
    d.id,
    d.transaction_id,
    d.transaction_status AS status,
    to_char(d.created_at, 'dd/mm/YYYY HH:MM'::text) AS data,
    COALESCE((d.customer -> 'name'::text), (a.name)::text) AS nome,
    d.email,
    COALESCE(customer_phone.number, activist_phone.number) AS telefone,
    d.payment_method AS "cartao/boleto",
        CASE
            WHEN d.subscription THEN 'Sim'::text
            ELSE 'Não'::text
        END AS recorrente,
    (((d.amount)::numeric / 100.0))::double precision AS valor,
    pd.value_without_fee AS "valor garantido",
    to_char(((d.gateway_data ->> 'boleto_expiration_date'::text))::timestamp without time zone, 'dd/mm/YYYY'::text) AS "data vencimento boleto",
    recurrency_donation.count AS "recorrencia da doacao",
    recurrency_activist.count AS "recorrencia do ativista"
   FROM ((((((((((donations d
     JOIN widgets w ON ((w.id = d.widget_id)))
     JOIN blocks b ON ((b.id = w.block_id)))
     JOIN mobilizations m ON ((m.id = b.mobilization_id)))
     JOIN communities c ON ((c.id = m.community_id)))
     LEFT JOIN payable_details pd ON ((pd.donation_id = d.id)))
     LEFT JOIN activists a ON ((a.id = d.activist_id)))
     LEFT JOIN LATERAL ( SELECT (((btrim(btrim((d.customer -> 'phone'::text)), '{}'::text))::hstore -> 'ddd'::text) || ((btrim(btrim((d.customer -> 'phone'::text)), '{}'::text))::hstore -> 'number'::text)) AS number) customer_phone ON (true))
     LEFT JOIN LATERAL ( SELECT (((btrim((a.phone)::text, '{}'::text))::hstore -> 'ddd'::text) || ((btrim((a.phone)::text, '{}'::text))::hstore -> 'number'::text)) AS number) activist_phone ON (true))
     LEFT JOIN LATERAL ( SELECT count(1) AS count
           FROM donations d2
          WHERE ((d2.subscription_id)::text = (d.subscription_id)::text)) recurrency_donation ON (true))
     LEFT JOIN LATERAL ( SELECT count(1) AS count
           FROM donations d2
          WHERE ((d2.activist_id = d.activist_id) AND (d.activist_id IS NOT NULL))) recurrency_activist ON (true));
}
  end
end
