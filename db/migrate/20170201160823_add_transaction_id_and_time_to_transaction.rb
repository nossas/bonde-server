# coding: utf-8
class AddTransactionIdAndTimeToTransaction < ActiveRecord::Migration
  def up
    execute %Q{
drop view public.donation_reports;
create or replace view public.donation_reports as
select
    m.id as mobilization_id,
    w.id as widget_id,
    c.id as community_id,
    d.id,
    d.transaction_id, 
    d.transaction_status as "status",
    to_char(d.created_at, 'dd/mm/YYYY HH:MM') as "data",
    coalesce(d.customer -> 'name', a.name) as "nome",
    d.email as "email",
    coalesce(customer_phone.number, activist_phone.number) as "telefone",
    d.payment_method as "cartao/boleto",
    (case when d.subscription then 'Sim' else 'Não' end) as "recorrente",
    (d.amount / 100.0)::double precision as "valor",
    pd.value_without_fee as "valor garantido",
    to_char((d.gateway_data ->> 'boleto_expiration_date')::timestamp, 'dd/mm/YYYY') as "data vencimento boleto",
    recurrency_donation.count as "recorrencia da doacao",
    recurrency_activist.count as "recorrencia do ativista"
    
from donations d
join widgets w on w.id = d.widget_id
join blocks b on b.id = w.block_id
join mobilizations m on m.id = b.mobilization_id
join communities c on c.id = m.community_id
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
drop view public.donation_reports;
create or replace view public.donation_reports as
select
    m.id as mobilization_id,
    w.id as widget_id,
    c.id as community_id,
    d.id,
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
    recurrency_activist.count as "recorrencia do ativista"
    
from donations d
join widgets w on w.id = d.widget_id
join blocks b on b.id = w.block_id
join mobilizations m on m.id = b.mobilization_id
join communities c on c.id = m.community_id
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
end
