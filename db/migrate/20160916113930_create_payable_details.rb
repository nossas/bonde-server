class CreatePayableDetails < ActiveRecord::Migration
  def up # rubocop:disable Metrics/MethodLength
    execute %Q{
DROP VIEW IF EXISTS public.payable_details;

CREATE OR REPLACE VIEW public.payable_details AS 
 SELECT o.id AS organization_id,
    w.id as widget_id,
    m.id as mobilization_id,
    b.id as block_id,
    d.id as donation_id,
    d.subscription_id as subscription_id,
    d.transaction_id,
    (dd.value ->> 'id'::text) AS payable_id,
    (d.amount / 100.0)::double precision as donation_value,    
    (((dd.value ->> 'amount'::text))::double precision / (100.0)::double precision) AS payable_value,
    (CASE
            WHEN ((d.payment_method)::text = 'boleto'::text) THEN (((dd.value ->> 'fee'::text))::double precision / (100.0)::double precision)
            ELSE ((COALESCE(((d.gateway_data ->> 'cost'::text))::double precision, (0.0)::double precision) / (100.0)::double precision) + (((dd.value ->> 'fee'::text))::double precision / (100.0)::double precision))
    END) AS fee,
    ((((dd.value ->> 'amount'::text))::double precision / (100.0)::double precision) - (((dd.value ->> 'fee'::text))::double precision / (100.0)::double precision)) AS value_without_fee,
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
   FROM organizations o
     JOIN mobilizations m ON (m.organization_id = o.id)
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
     LEFT JOIN LATERAL ( SELECT
                CASE
                    WHEN (date_part('day'::text, ((dd.value ->> 'payment_date'::text))::timestamp without time zone) > (COALESCE(NULLIF(o.transfer_day, 0), 5))::double precision) THEN (make_date((date_part('year'::text, ((dd.value ->> 'payment_date'::text))::timestamp without time zone))::integer, (date_part('month'::text, (((dd.value ->> 'payment_date'::text))::timestamp without time zone + '1 mon'::interval)))::integer, COALESCE(NULLIF(o.transfer_day, 0), 5)))::timestamp without time zone
                    ELSE ((dd.value ->> 'payment_date'::text))::timestamp without time zone
                END AS receive_period) transfer_d ON (true)
  WHERE (((dd.value ->> 'type'::text) = 'credit'::text) AND ((dd.value ->> 'object'::text) = 'payable'::text) AND (dd.value->>'recipient_id'::text = o.pagarme_recipient_id) OR d.subscription);
    }
    # rubocop:enable Metrics/MethodLength
  end

  def down
    execute %Q{
DROP VIEW IF EXISTS public.payable_details;
    }
  end
end
