class AddCustomerAddressToAggActivists < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE VIEW "agg_activists" AS 
    SELECT com.id AS community_id,
        a.id AS activist_id,
        a.email,
        a.name,
        (((btrim((a.phone)::text, '{}'::text))::hstore -> 'ddd'::text) || ((btrim((a.phone)::text, '{}'::text))::hstore -> 'number'::text)) AS phone,
        count(DISTINCT fe.id) AS total_form_entries,
        count(DISTINCT d.id) AS total_donations,
        count(DISTINCT ap.id) AS total_pressures,
        ((count(DISTINCT fe.id) + count(DISTINCT d.id)) + count(DISTINCT ap.id)) AS total_actions,
        last_donation.transaction_status AS last_donation_status,
        (last_donation.amount / 100) AS last_donation_amount,
        last_donation.subscription AS last_donation_is_subscription,
        last_customer.address -> 'street' as address_street,
        last_customer.address -> 'street_number' as street_number,
        last_customer.address -> 'neighborhood' as neighborhood,
        last_customer.address -> 'complementary' as complementary,
        last_customer.address -> 'city' as city,
        last_customer.address -> 'state' as state
    FROM ((((((((communities com
     LEFT JOIN mobilizations m ON ((m.community_id = com.id)))
     LEFT JOIN blocks b ON ((b.mobilization_id = m.id)))
     LEFT JOIN widgets w ON ((w.block_id = b.id)))
     LEFT JOIN form_entries fe ON ((fe.widget_id = w.id)))
     LEFT JOIN donations d ON (((d.widget_id = w.id) AND (d.transaction_id IS NOT NULL) AND (d.transaction_status IS NOT NULL))))
     LEFT JOIN activist_pressures ap ON ((ap.widget_id = w.id)))
     LEFT JOIN activists a ON (((a.id = fe.activist_id) OR (a.id = d.activist_id) OR (a.id = ap.activist_id))))
     LEFT JOIN LATERAL (
        SELECT
            btrim(d2.customer->'address', '{}')::hstore as address 
        FROM donations d2
        WHERE ((d2.activist_id = a.id) AND (d2.transaction_id IS NOT NULL) AND (d2.transaction_status IS NOT NULL) AND d2.customer is not null)
        ORDER BY d2.id DESC
        LIMIT 1    
     ) as last_customer on true
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
    GROUP BY com.id, a.email, a.id, last_donation.transaction_status, last_donation.amount, last_donation.subscription, last_customer.address;
}
  end

  def down
    execute %Q{
    DROP VIEW agg_activists;
CREATE OR REPLACE VIEW "agg_activists" AS 
 SELECT com.id AS community_id,
    a.id AS activist_id,
    a.email,
    a.name,
    (((btrim((a.phone)::text, '{}'::text))::hstore -> 'ddd'::text) || ((btrim((a.phone)::text, '{}'::text))::hstore -> 'number'::text)) AS phone,
    count(DISTINCT fe.id) AS total_form_entries,
    count(DISTINCT d.id) AS total_donations,
    count(DISTINCT ap.id) AS total_pressures,
    ((count(DISTINCT fe.id) + count(DISTINCT d.id)) + count(DISTINCT ap.id)) AS total_actions,
    last_donation.transaction_status AS last_donation_status,
    (last_donation.amount / 100) AS last_donation_amount,
    last_donation.subscription AS last_donation_is_subscription
   FROM ((((((((communities com
     LEFT JOIN mobilizations m ON ((m.community_id = com.id)))
     LEFT JOIN blocks b ON ((b.mobilization_id = m.id)))
     LEFT JOIN widgets w ON ((w.block_id = b.id)))
     LEFT JOIN form_entries fe ON ((fe.widget_id = w.id)))
     LEFT JOIN donations d ON (((d.widget_id = w.id) AND (d.transaction_id IS NOT NULL) AND (d.transaction_status IS NOT NULL))))
     LEFT JOIN activist_pressures ap ON ((ap.widget_id = w.id)))
     LEFT JOIN activists a ON (((a.id = fe.activist_id) OR (a.id = d.activist_id) OR (a.id = ap.activist_id))))
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
            d2.old_synch AS synchronized,
            d2.converted_from
           FROM donations d2
          WHERE ((d2.activist_id = a.id) AND (d2.transaction_id IS NOT NULL) AND (d2.transaction_status IS NOT NULL))
          ORDER BY d2.id DESC
         LIMIT 1) last_donation ON (true))
  WHERE (a.id IS NOT NULL)
  GROUP BY com.id, a.email, a.id, last_donation.transaction_status, last_donation.amount, last_donation.subscription;
}
  end
end
