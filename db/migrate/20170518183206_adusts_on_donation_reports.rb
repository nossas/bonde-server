# coding: utf-8
class AdustsOnDonationReports < ActiveRecord::Migration
  def change
    execute %Q{
drop view donation_reports;
drop view payable_details;

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
    (payable_summary.payable_fee)::double precision AS payable_pagarme_fee,
        CASE
            WHEN (jsonb_array_length(d.payables) > 1) THEN nossas_tx.amount
            ELSE ((((d.amount)::numeric / 100.0) * 0.13))::double precision
        END AS nossas_fee,
    nossas_tx.percent AS percent_tx,
        CASE
            WHEN (jsonb_array_length(d.payables) > 1) THEN ((((dd.value ->> 'amount'::text))::double precision / (100.0)::double precision) - (payable_summary.payable_fee)::double precision)
            ELSE ((((d.amount)::numeric / 100.0))::double precision - ((((d.amount)::numeric / 100.0) * 0.13))::double precision)
        END AS value_without_fee,
    ((dd.value ->> 'date_created'::text))::timestamp without time zone AS payment_date,
    ((dd.value ->> 'payment_date'::text))::timestamp without time zone AS payable_date,
    d.transaction_status AS pagarme_status,
    (dd.value ->> 'status'::text) AS payable_status,
    d.payment_method,
    customer.name,
    customer.email,
    pt.id AS payable_transfer_id,
    pt.transfer_data,
    d.gateway_data,
    d.subscription AS is_subscription,
    (dd.value ->> 'recipient_id'::text) AS recipient_id,
    d.local_subscription_id
   FROM (((((((((communities o
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
     LEFT JOIN LATERAL ( SELECT (((jsonb_array_elements.value ->> 'amount'::text))::double precision / (100.0)::double precision) AS amount,
            ((((jsonb_array_elements.value ->> 'amount'::text))::double precision / (d.amount)::double precision) * (100.0)::double precision) AS percent
           FROM jsonb_array_elements(d.payables) jsonb_array_elements(value)
          WHERE ((jsonb_array_elements.value ->> 'recipient_id'::text) = nossas_recipient_id())) nossas_tx ON (true))
     LEFT JOIN LATERAL ( SELECT td.amount,
            td.payable_fee,
            td.transaction_cost,
            (td.amount - td.payable_fee) AS value_without_fee
           FROM ( SELECT ((((dd.value ->> 'amount'::text))::integer)::numeric / 100.0) AS amount,
                    ((((dd.value ->> 'fee'::text))::integer)::numeric / 100.0) AS payable_fee,
                    ((((d.gateway_data ->> 'cost'::text))::integer)::numeric / 100.0) AS transaction_cost) td) payable_summary ON (true))
  WHERE ((((dd.value ->> 'type'::text) = 'credit'::text) AND ((dd.value ->> 'object'::text) = 'payable'::text) AND ((dd.value ->> 'recipient_id'::text) IN ( SELECT (r.pagarme_recipient_id)::text AS pagarme_recipient_id
           FROM recipients r
          WHERE (r.community_id = o.id)))) OR (jsonb_array_length(d.payables) = 1));

CREATE OR REPLACE VIEW "donation_reports" AS 
 SELECT m.id AS mobilization_id,
    w.id AS widget_id,
    c.id AS community_id,
    d.id,
    d.transaction_id,
    d.transaction_status AS status,
    to_char(d.created_at, 'dd/mm/YYYY'::text) AS data,
    COALESCE((d.customer -> 'name'::text), (a.name)::text) AS nome,
    d.email,
    COALESCE(customer_phone.number, activist_phone.number) AS telefone,
    d.payment_method AS "cartao/boleto",
        CASE
            WHEN (d.subscription OR d.local_subscription_id is not null) THEN 'Sim'::text
            ELSE 'Não'::text
        END AS recorrente,
    (((d.amount)::numeric / 100.0))::double precision AS valor,
    pd.value_without_fee AS "valor garantido",
    to_char(((d.gateway_data ->> 'boleto_expiration_date'::text))::timestamp without time zone, 'dd/mm/YYYY'::text) AS "data vencimento boleto",
    recurrency_donation.count AS "recorrencia da doacao",
    recurrency_activist.count AS "recorrencia do ativista",
    (gs.status)::text AS subscription_status
   FROM (((((((((((donations d
     JOIN widgets w ON ((w.id = d.widget_id)))
     JOIN blocks b ON ((b.id = w.block_id)))
     JOIN mobilizations m ON ((m.id = b.mobilization_id)))
     JOIN communities c ON ((c.id = m.community_id)))
     LEFT JOIN subscriptions gs ON ((gs.id = d.local_subscription_id)))
     LEFT JOIN payable_details pd ON ((pd.donation_id = d.id)))
     LEFT JOIN activists a ON ((a.id = d.activist_id)))
     LEFT JOIN LATERAL ( SELECT (((btrim(btrim((d.customer -> 'phone'::text)), '{}'::text))::hstore -> 'ddd'::text) || ((btrim(btrim((d.customer -> 'phone'::text)), '{}'::text))::hstore -> 'number'::text)) AS number) customer_phone ON (true))
     LEFT JOIN LATERAL ( SELECT (((btrim((a.phone)::text, '{}'::text))::hstore -> 'ddd'::text) || ((btrim((a.phone)::text, '{}'::text))::hstore -> 'number'::text)) AS number) activist_phone ON (true))
     LEFT JOIN LATERAL ( SELECT count(1) AS count
           FROM donations d2
          WHERE (d2.local_subscription_id is not null and(d2.local_subscription_id)::text = (d.local_subscription_id)::text)) recurrency_donation ON (true))
     LEFT JOIN LATERAL ( SELECT count(1) AS count
           FROM donations d2
          WHERE ((d2.activist_id = d.activist_id) AND (d.activist_id IS NOT NULL))) recurrency_activist ON (true));

CREATE OR REPLACE VIEW "donation_reports" AS 
 SELECT m.id AS mobilization_id,
    w.id AS widget_id,
    c.id AS community_id,
    d.id,
    d.transaction_id,
    d.transaction_status AS status,
    to_char(d.created_at, 'dd/mm/YYYY'::text) AS data,
    COALESCE((d.customer -> 'name'::text), (a.name)::text) AS nome,
    d.email,
    COALESCE(customer_phone.number, activist_phone.number) AS telefone,
    d.payment_method AS "cartao/boleto",
        CASE
            WHEN (d.subscription OR d.local_subscription_id is not null) THEN 'Sim'::text
            ELSE 'Não'::text
        END AS recorrente,
    (((d.amount)::numeric / 100.0))::double precision AS valor,
    pd.value_without_fee AS "valor garantido",
    to_char(((d.gateway_data ->> 'boleto_expiration_date'::text))::timestamp without time zone, 'dd/mm/YYYY'::text) AS "data vencimento boleto",
    recurrency_donation.count AS "recorrencia da doacao",
    recurrency_activist.count AS "recorrencia do ativista",
    (gs.status)::text AS subscription_status
   FROM (((((((((((donations d
     JOIN widgets w ON ((w.id = d.widget_id)))
     JOIN blocks b ON ((b.id = w.block_id)))
     JOIN mobilizations m ON ((m.id = b.mobilization_id)))
     JOIN communities c ON ((c.id = m.community_id)))
     LEFT JOIN subscriptions gs ON ((gs.id = d.local_subscription_id)))
     LEFT JOIN payable_details pd ON ((pd.donation_id = d.id)))
     LEFT JOIN activists a ON ((a.id = d.activist_id)))
     LEFT JOIN LATERAL ( SELECT (((btrim(btrim((d.customer -> 'phone'::text)), '{}'::text))::hstore -> 'ddd'::text) || ((btrim(btrim((d.customer -> 'phone'::text)), '{}'::text))::hstore -> 'number'::text)) AS number) customer_phone ON (true))
     LEFT JOIN LATERAL ( SELECT (((btrim((a.phone)::text, '{}'::text))::hstore -> 'ddd'::text) || ((btrim((a.phone)::text, '{}'::text))::hstore -> 'number'::text)) AS number) activist_phone ON (true))
     LEFT JOIN LATERAL ( SELECT count(1) AS count
           FROM donations d2
          WHERE (d2.local_subscription_id is not null and(d2.local_subscription_id)::text = (d.local_subscription_id)::text)) recurrency_donation ON (true))
     LEFT JOIN LATERAL ( SELECT count(1) AS count
           FROM donations d2
          WHERE ((d2.activist_id = d.activist_id) AND (d.activist_id IS NOT NULL))) recurrency_activist ON (true));
}
  end
end
