class AdjustDonationsPaymentDate < ActiveRecord::Migration
  def change
    execute %Q{
CREATE OR REPLACE VIEW "postgraphql"."donations" AS 
 SELECT d.id AS donation_id,
    c.id AS community_id,
    w.id AS widget_id,
    m.id AS mobilization_id,
    b.id AS block_id,
    d.activist_id,
    d.email AS donation_email,
    (d.amount / 100) AS donation_amount,
    d.local_subscription_id AS subscription_id,
    d.transaction_status,
    coalesce((d.gateway_data->>'date_created')::timestamp without time zone, d.created_at)::timestamp without time zone as payment_date,
    pd.payable_date,
    pd.payable_value AS payable_amount,
    pd.payable_status,
    s.status AS subscription_status
   FROM ((((((donations d
     JOIN widgets w ON ((w.id = d.widget_id)))
     JOIN blocks b ON ((b.id = w.block_id)))
     JOIN mobilizations m ON ((m.id = b.mobilization_id)))
     JOIN communities c ON ((c.id = m.community_id)))
     LEFT JOIN subscriptions s ON ((s.id = d.local_subscription_id)))
     LEFT JOIN payable_details pd ON ((pd.donation_id = d.id)))
  WHERE ((d.transaction_id IS NOT NULL) AND (c.id IN ( SELECT community_user_roles.community_id
           FROM postgraphql.community_user_roles)));
}
  end
end
