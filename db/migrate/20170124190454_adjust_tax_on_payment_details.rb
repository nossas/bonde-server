class AdjustTaxOnPaymentDetails < ActiveRecord::Migration
  def up # rubocop:disable Metrics/MethodLength
    execute %Q{
create or replace function nossas_recipient_id() returns text
language SQL as $$
         select 'RECIPIENT_ID_HERE'::text;
$$;
DROP VIEW public.payable_details;
CREATE OR REPLACE VIEW public.payable_details AS 
 SELECT o.id AS community_id,
    w.id as widget_id,
    m.id as mobilization_id,
    b.id as block_id,
    d.id as donation_id,
    d.subscription_id as subscription_id,
    d.transaction_id,
    (dd.value ->> 'id'::text) AS payable_id,
    (d.amount / 100.0)::double precision as donation_value,
    (((dd.value ->> 'amount'::text))::double precision / (100.0)::double precision) AS payable_value,
    (payable_summary.payable_fee)::double precision AS payable_pagarme_fee,
    (
        CASE WHEN not d.subscription THEN
            nossas_tx.amount
        ELSE
            (d.amount / 100.0) * 0.13
        END
    )::double precision AS nossas_fee,
    nossas_tx.percent as percent_tx,
    (
        CASE WHEN not d.subscription THEN
            (((dd.value ->> 'amount'::text))::double precision / (100.0)::double precision) - payable_summary.payable_fee
        ELSE
            (d.amount / 100.0) - ((d.amount / 100.0) * 0.13)::double precision
        END
    ) AS value_without_fee,
    ((dd.value ->> 'date_created'::text))::timestamp without time zone AS payment_date,
    ((dd.value ->> 'payment_date'::text))::timestamp without time zone AS payable_date,
    d.transaction_status AS pagarme_status,
    (dd.value ->> 'status'::text) AS payable_status,
    transfer_d.receive_period,
    d.payment_method,
    customer.*,
    pt.id as payable_transfer_id,
    pt.transfer_data,
    d.gateway_data
   FROM communities o
     JOIN mobilizations m ON (m.community_id = o.id)
     JOIN blocks b ON (b.mobilization_id = m.id)
     JOIN widgets w ON (w.block_id = b.id) AND ((w.kind)::text = 'donation'::text)
     JOIN donations d ON (d.widget_id = w.id) AND ((d.transaction_status)::text = 'paid'::text)
     LEFT JOIN payable_transfers pt ON pt.id = d.payable_transfer_id
     LEFT JOIN LATERAL (
        select
            coalesce(d2.customer->'name', d.customer->'name') as name,
            coalesce(d2.customer->'email', d.customer->'email') as email
        from donations d2 
        where 
        CASE WHEN d.parent_id is null then
            d2.id = d.id
        else d2.id = d.parent_id end
     ) as customer on true
     LEFT JOIN LATERAL ( SELECT data.value
           FROM jsonb_array_elements(d.payables) data(value)
    ) dd ON (true)
     LEFT JOIN LATERAL (
        SELECT
            ((value->>'amount')::double precision/100.0) as amount,
            ((value->>'amount')::double precision / d.amount::double precision)::double precision * 100.0 as percent
        FROM jsonb_array_elements(d.payables) 
        where value->>'recipient_id'= public.nossas_recipient_id()
     ) nossas_tx on (true)
     LEFT JOIN LATERAL (
        select
            td.*,
            td.amount - td.payable_fee as value_without_fee
        from (
            select
                ((dd.value ->> 'amount')::int / 100.0) as amount,
                ((dd.value ->> 'fee')::int / 100.0) as payable_fee,
                ((d.gateway_data ->> 'cost')::int / 100.0) as transaction_cost
        ) as td
     ) payable_summary on (true)
     LEFT JOIN LATERAL ( SELECT
                CASE
                    WHEN (date_part('day'::text, ((dd.value ->> 'payment_date'::text))::timestamp without time zone) > (COALESCE(NULLIF(o.transfer_day, 0), 5))::double precision) THEN (make_date((date_part('year'::text, ((dd.value ->> 'payment_date'::text))::timestamp without time zone))::integer, (date_part('month'::text, (((dd.value ->> 'payment_date'::text))::timestamp without time zone + '1 mon'::interval)))::integer, COALESCE(NULLIF(o.transfer_day, 0), 5)))::timestamp without time zone
                    ELSE ((dd.value ->> 'payment_date'::text))::timestamp without time zone
                END AS receive_period) transfer_d ON (true)
  WHERE (((dd.value ->> 'type'::text) = 'credit'::text) AND ((dd.value ->> 'object'::text) = 'payable'::text) AND (dd.value->>'recipient_id'::text = o.pagarme_recipient_id) OR d.subscription);

}
    # rubocop:enable Metrics/MethodLength
  end

  def down # rubocop:disable Metrics/MethodLength
    execute %Q{
DROP VIEW public.payable_details;
CREATE OR REPLACE VIEW "payable_details" AS 
 SELECT o.id AS community_id,
    w.id AS widget_id,
    m.id AS mobilization_id,
    b.id AS block_id,
    d.id AS donation_id,
    d.subscription_id,
    d.transaction_id,
    (dd.value ->> 'id'::text) AS payable_id,
    (((d.amount)::numeric / 100.0))::double precision AS donation_value,
    (((dd.value ->> 'amount'::text))::double precision / (100.0)::double precision) AS payable_value,
        CASE
            WHEN ((d.payment_method)::text = 'boleto'::text) THEN (((dd.value ->> 'fee'::text))::double precision / (100.0)::double precision)
            ELSE ((COALESCE(((d.gateway_data ->> 'cost'::text))::double precision, (0.0)::double precision) / (100.0)::double precision) + (((dd.value ->> 'fee'::text))::double precision / (100.0)::double precision))
        END AS fee,
    ((((dd.value ->> 'amount'::text))::double precision / (100.0)::double precision) - (((dd.value ->> 'fee'::text))::double precision / (100.0)::double precision)) AS value_without_fee,
    ((dd.value ->> 'date_created'::text))::timestamp without time zone AS payment_date,
    ((dd.value ->> 'payment_date'::text))::timestamp without time zone AS payable_date,
    d.transaction_status AS pagarme_status,
    (dd.value ->> 'status'::text) AS payable_status,
    transfer_d.receive_period,
    d.payment_method,
    customer.name,
    customer.email,
    pt.id AS payable_transfer_id,
    pt.transfer_data,
    d.gateway_data
   FROM ((((((((communities o
     JOIN mobilizations m ON ((m.community_id = o.id)))
     JOIN blocks b ON ((b.mobilization_id = m.id)))
     JOIN widgets w ON (((w.block_id = b.id) AND ((w.kind)::text = 'donation'::text))))
     JOIN donations d ON (((d.widget_id = w.id) AND ((d.transaction_status)::text = 'paid'::text))))
     LEFT JOIN payable_transfers pt ON ((pt.id = d.payable_transfer_id)))
     LEFT JOIN LATERAL ( SELECT COALESCE((d2.customer -> 'name'::text), (d.customer -> 'name'::text)) AS name,
            COALESCE((d2.customer -> 'email'::text), (d.customer -> 'email'::text)) AS email
           FROM donations d2
          WHERE
                CASE
                    WHEN (d.parent_id IS NULL) THEN (d2.id = d.id)
                    ELSE (d2.id = d.parent_id)
                END) customer ON (true))
     LEFT JOIN LATERAL ( SELECT data.value
           FROM jsonb_array_elements(d.payables) data(value)) dd ON (true))
     LEFT JOIN LATERAL ( SELECT
                CASE
                    WHEN (date_part('day'::text, ((dd.value ->> 'payment_date'::text))::timestamp without time zone) > (COALESCE(NULLIF(o.pagarme_transfer_day, 0), 5))::double precision) THEN (make_date((date_part('year'::text, ((dd.value ->> 'payment_date'::text))::timestamp without time zone))::integer, (date_part('month'::text, (((dd.value ->> 'payment_date'::text))::timestamp without time zone + '1 mon'::interval)))::integer, COALESCE(NULLIF(o.pagarme_transfer_day, 0), 5)))::timestamp without time zone
                    ELSE ((dd.value ->> 'payment_date'::text))::timestamp without time zone
                END AS receive_period) transfer_d ON (true))
  WHERE ((((dd.value ->> 'type'::text) = 'credit'::text) AND ((dd.value ->> 'object'::text) = 'payable'::text) AND ((dd.value ->> 'recipient_id'::text) = (o.pagarme_recipient_id_old)::text)) OR d.subscription);
}
    # rubocop:enable Metrics/MethodLength
  end
end
