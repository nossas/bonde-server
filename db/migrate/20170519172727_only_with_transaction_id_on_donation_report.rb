# coding: utf-8
class OnlyWithTransactionIdOnDonationReport < ActiveRecord::Migration
  def change
    execute %Q{
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
            WHEN (d.subscription OR (d.local_subscription_id IS NOT NULL)) THEN 'Sim'::text
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
          WHERE ((d2.local_subscription_id IS NOT NULL) AND ((d2.local_subscription_id)::text = (d.local_subscription_id)::text))) recurrency_donation ON (true))
     LEFT JOIN LATERAL ( SELECT count(1) AS count
           FROM donations d2
          WHERE ((d2.activist_id = d.activist_id) AND (d.activist_id IS NOT NULL))) recurrency_activist ON (true))
  WHERE (d.transaction_id IS NOT NULL);
}
  end
end
