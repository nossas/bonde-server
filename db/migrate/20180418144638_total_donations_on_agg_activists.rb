class TotalDonationsOnAggActivists < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE VIEW "agg_activists" AS 
 SELECT com.id AS community_id,
    a.id AS activist_id,
    a.email,
    a.name,
    (((btrim((a.phone)::text, '{}'::text))::hstore -> 'ddd'::text) || ((btrim((a.phone)::text, '{}'::text))::hstore -> 'number'::text)) AS phone,
    agg_fe.count AS total_form_entries,
    agg_do.count AS total_donations,
    agg_ap.count AS total_pressures,
    ((agg_fe.count + agg_do.count) + agg_ap.count) AS total_actions,
    last_donation.transaction_status AS last_donation_status,
    (last_donation.amount / 100) AS last_donation_amount,
    last_donation.subscription AS last_donation_is_subscription,
    (last_customer.address -> 'street'::text) AS address_street,
    (last_customer.address -> 'street_number'::text) AS street_number,
    (last_customer.address -> 'neighborhood'::text) AS neighborhood,
    (last_customer.address -> 'complementary'::text) AS complementary,
    (last_customer.address -> 'city'::text) AS city,
    (last_customer.address -> 'state'::text) AS state
   FROM (((((((communities com
     JOIN community_activists cac ON ((cac.community_id = com.id)))
     JOIN activists a ON ((a.id = cac.activist_id)))
     LEFT JOIN LATERAL ( SELECT count(1) AS count
           FROM (((form_entries fe
             JOIN widgets w ON ((w.id = fe.widget_id)))
             JOIN blocks b ON ((b.id = w.block_id)))
             JOIN mobilizations m ON ((b.mobilization_id = m.id)))
          WHERE ((fe.activist_id = a.id) AND (m.community_id = com.id))) agg_fe ON (true))
     LEFT JOIN LATERAL ( SELECT count(1) AS count
           FROM (((donations d
             JOIN widgets w ON ((w.id = d.widget_id)))
             JOIN blocks b ON ((b.id = w.block_id)))
             JOIN mobilizations m ON ((b.mobilization_id = m.id)))
          WHERE ((d.transaction_status = 'paid') AND (d.activist_id = a.id) AND (m.community_id = com.id))) agg_do ON (true))
     LEFT JOIN LATERAL ( SELECT count(1) AS count
           FROM (((activist_pressures ap
             JOIN widgets w ON ((w.id = ap.widget_id)))
             JOIN blocks b ON ((b.id = w.block_id)))
             JOIN mobilizations m ON ((b.mobilization_id = m.id)))
          WHERE ((ap.activist_id = a.id) AND (m.community_id = com.id))) agg_ap ON (true))
     LEFT JOIN LATERAL ( SELECT (btrim((d2.customer -> 'address'::text), '{}'::text))::hstore AS address
           FROM donations d2
          WHERE ((d2.activist_id = a.id) AND (d2.transaction_id IS NOT NULL) AND (d2.transaction_status IS NOT NULL) AND (d2.customer IS NOT NULL))
          ORDER BY d2.id DESC
         LIMIT 1) last_customer ON (true))
     LEFT JOIN LATERAL ( SELECT d2.id,
            d2.widget_id,
            d2.created_at,
            d2.updated_at,
            d2.token,
            d2.payment_method,
            d2.amount,
            d2.email,
            d2.card_hash,
            d2.customer,
            d2.skip,
            d2.transaction_id,
            d2.transaction_status,
            d2.subscription,
            d2.credit_card,
            d2.activist_id,
            d2.subscription_id,
            d2.period,
            d2.plan_id,
            d2.parent_id,
            d2.payables,
            d2.gateway_data,
            d2.payable_transfer_id,
            d2.converted_from
           FROM donations d2
          WHERE ((d2.activist_id = a.id) AND (d2.transaction_id IS NOT NULL) AND (d2.transaction_status IS NOT NULL))
          ORDER BY d2.id DESC
         LIMIT 1) last_donation ON (true))
  WHERE (a.id IS NOT NULL)
  GROUP BY com.id, a.email, a.id, last_donation.transaction_status, last_donation.amount, last_donation.subscription, last_customer.address, agg_fe.count, agg_do.count, agg_ap.count;
}
  end

  def down
    execute %Q{
CREATE OR REPLACE VIEW "agg_activists" AS 
 SELECT com.id AS community_id,
    a.id AS activist_id,
    a.email,
    a.name,
    (((btrim((a.phone)::text, '{}'::text))::hstore -> 'ddd'::text) || ((btrim((a.phone)::text, '{}'::text))::hstore -> 'number'::text)) AS phone,
    agg_fe.count AS total_form_entries,
    agg_do.count AS total_donations,
    agg_ap.count AS total_pressures,
    ((agg_fe.count + agg_do.count) + agg_ap.count) AS total_actions,
    last_donation.transaction_status AS last_donation_status,
    (last_donation.amount / 100) AS last_donation_amount,
    last_donation.subscription AS last_donation_is_subscription,
    (last_customer.address -> 'street'::text) AS address_street,
    (last_customer.address -> 'street_number'::text) AS street_number,
    (last_customer.address -> 'neighborhood'::text) AS neighborhood,
    (last_customer.address -> 'complementary'::text) AS complementary,
    (last_customer.address -> 'city'::text) AS city,
    (last_customer.address -> 'state'::text) AS state
   FROM (((((((communities com
     JOIN community_activists cac ON ((cac.community_id = com.id)))
     JOIN activists a ON ((a.id = cac.activist_id)))
     LEFT JOIN LATERAL ( SELECT count(1) AS count
           FROM (((form_entries fe
             JOIN widgets w ON ((w.id = fe.widget_id)))
             JOIN blocks b ON ((b.id = w.block_id)))
             JOIN mobilizations m ON ((b.mobilization_id = m.id)))
          WHERE ((fe.activist_id = a.id) AND (m.community_id = com.id))) agg_fe ON (true))
     LEFT JOIN LATERAL ( SELECT count(1) AS count
           FROM (((donations d
             JOIN widgets w ON ((w.id = d.widget_id)))
             JOIN blocks b ON ((b.id = w.block_id)))
             JOIN mobilizations m ON ((b.mobilization_id = m.id)))
          WHERE ((d.activist_id = a.id) AND (m.community_id = com.id))) agg_do ON (true))
     LEFT JOIN LATERAL ( SELECT count(1) AS count
           FROM (((activist_pressures ap
             JOIN widgets w ON ((w.id = ap.widget_id)))
             JOIN blocks b ON ((b.id = w.block_id)))
             JOIN mobilizations m ON ((b.mobilization_id = m.id)))
          WHERE ((ap.activist_id = a.id) AND (m.community_id = com.id))) agg_ap ON (true))
     LEFT JOIN LATERAL ( SELECT (btrim((d2.customer -> 'address'::text), '{}'::text))::hstore AS address
           FROM donations d2
          WHERE ((d2.activist_id = a.id) AND (d2.transaction_id IS NOT NULL) AND (d2.transaction_status IS NOT NULL) AND (d2.customer IS NOT NULL))
          ORDER BY d2.id DESC
         LIMIT 1) last_customer ON (true))
     LEFT JOIN LATERAL ( SELECT d2.id,
            d2.widget_id,
            d2.created_at,
            d2.updated_at,
            d2.token,
            d2.payment_method,
            d2.amount,
            d2.email,
            d2.card_hash,
            d2.customer,
            d2.skip,
            d2.transaction_id,
            d2.transaction_status,
            d2.subscription,
            d2.credit_card,
            d2.activist_id,
            d2.subscription_id,
            d2.period,
            d2.plan_id,
            d2.parent_id,
            d2.payables,
            d2.gateway_data,
            d2.payable_transfer_id,
            d2.converted_from
           FROM donations d2
          WHERE ((d2.activist_id = a.id) AND (d2.transaction_id IS NOT NULL) AND (d2.transaction_status IS NOT NULL))
          ORDER BY d2.id DESC
         LIMIT 1) last_donation ON (true))
  WHERE (a.id IS NOT NULL)
  GROUP BY com.id, a.email, a.id, last_donation.transaction_status, last_donation.amount, last_donation.subscription, last_customer.address, agg_fe.count, agg_do.count, agg_ap.count;
}
  end
end
