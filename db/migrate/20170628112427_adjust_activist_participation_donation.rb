class AdjustActivistParticipationDonation < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE VIEW "activist_participations" AS 
 SELECT c.id AS community_id,
    m.id AS mobilization_id,
    w.id AS widget_id,
    a.id AS activist_id,
    a.email,
    COALESCE(fe.created_at, d.created_at, ap.created_at, s.created_at) AS participate_at,
        CASE
            WHEN (fe.id IS NOT NULL) THEN 'form_entry'::text
            WHEN (d.id IS NOT NULL AND d.local_subscription_id IS NOT NULL) THEN 'subscription'::text
            WHEN (d.id IS NOT NULL AND d.local_subscription_id IS NULL) THEN 'donation'::text
            WHEN (ap.id IS NOT NULL) THEN 'activist_pressure'::text
            WHEN (s.id IS NOT NULL) THEN 'subscription'::text
            ELSE NULL::text
        END AS participate_kind,
    COALESCE(fe.id, d.id, ap.id, s.id) AS participate_id
   FROM ((((((((communities c
     JOIN mobilizations m ON ((m.community_id = c.id)))
     LEFT JOIN blocks b ON ((b.mobilization_id = m.id)))
     LEFT JOIN widgets w ON ((w.block_id = b.id)))
     LEFT JOIN form_entries fe ON ((fe.widget_id = w.id)))
     LEFT JOIN donations d ON (((d.widget_id = w.id) AND (NOT d.subscription))))
     LEFT JOIN subscriptions s ON ((s.widget_id = w.id)))
     LEFT JOIN activist_pressures ap ON ((ap.widget_id = w.id)))
     JOIN activists a ON ((a.id = COALESCE(fe.activist_id, d.activist_id, s.activist_id, ap.activist_id))))
  GROUP BY c.id, m.id, w.id, a.id, fe.id, s.id, ap.id, d.id, fe.created_at, s.created_at, ap.created_at, d.created_at;
}
  end

  def down
    execute %Q{
CREATE OR REPLACE VIEW public.activist_participations AS
 SELECT c.id AS community_id,
    m.id AS mobilization_id,
    w.id AS widget_id,
    a.id AS activist_id,
    a.email,
    COALESCE(fe.created_at, d.created_at, ap.created_at, s.created_at) AS participate_at,
        CASE
            WHEN (fe.id IS NOT NULL) THEN 'form_entry'::text
            WHEN (d.id IS NOT NULL) THEN 'donation'::text
            WHEN (ap.id IS NOT NULL) THEN 'activist_pressure'::text
            WHEN (s.id IS NOT NULL) THEN 'subscription'::text
            ELSE NULL::text
        END AS participate_kind,
    COALESCE(fe.id, d.id, ap.id, s.id) AS participate_id
   FROM ((((((((communities c
     JOIN mobilizations m ON ((m.community_id = c.id)))
     LEFT JOIN blocks b ON ((b.mobilization_id = m.id)))
     LEFT JOIN widgets w ON ((w.block_id = b.id)))
     LEFT JOIN form_entries fe ON ((fe.widget_id = w.id)))
     LEFT JOIN donations d ON (((d.widget_id = w.id) AND (NOT d.subscription))))
     LEFT JOIN subscriptions s ON ((s.widget_id = w.id)))
     LEFT JOIN activist_pressures ap ON ((ap.widget_id = w.id)))
     JOIN activists a ON ((a.id = COALESCE(fe.activist_id, d.activist_id, s.activist_id, ap.activist_id))))
  GROUP BY c.id, m.id, w.id, a.id, fe.id, s.id, ap.id, d.id, fe.created_at, s.created_at, ap.created_at, d.created_at;
}
  end
end
