class AdjustActivistsToUseCommunityActivists < ActiveRecord::Migration
  def up
    execute %Q{
grant select on public.community_activists to common_user, admin;
grant select on public.mobilization_activists to common_user, admin;
CREATE OR REPLACE VIEW "postgraphql"."activists" AS 
    with current_communities_access as (
        select distinct(cu.community_id)
        from community_users cu
            where (cu.user_id = postgraphql.current_user_id() 
            or current_role = 'admin')
    ) SELECT ca.community_id AS community_id,
    a.id,
    a.name,
    a.email,
    a.phone,
    a.document_number,
    a.created_at,
    row_to_json(a.*) AS data,
    '{}'::json AS mobilizations,
    '{}'::jsonb AS tags
   FROM community_activists ca
     JOIN activists a ON a.id = ca.activist_id
   where  ca.community_id in (select community_id from current_communities_access)
  GROUP BY a.id, ca.community_id;
}
  end

  def down
    execute %Q{
CREATE OR REPLACE VIEW "postgraphql"."activists" AS
 SELECT c.id AS community_id,
    a.id,
    a.name,
    a.email,
    a.phone,
    a.document_number,
    a.created_at,
    row_to_json(a.*) AS data,
    json_agg(DISTINCT m.*) AS mobilizations,
    '{}'::jsonb AS tags
   FROM ((((((((communities c
     JOIN mobilizations m ON ((m.community_id = c.id)))
     LEFT JOIN blocks b ON ((b.mobilization_id = m.id)))
     LEFT JOIN widgets w ON ((w.block_id = b.id)))
     LEFT JOIN form_entries fe ON ((fe.widget_id = w.id)))
     LEFT JOIN donations d ON (((d.widget_id = w.id) AND (NOT d.subscription))))
     LEFT JOIN subscriptions s ON ((s.widget_id = w.id)))
     LEFT JOIN activist_pressures ap ON ((ap.widget_id = w.id)))
     JOIN activists a ON ((a.id = COALESCE(fe.activist_id, d.activist_id, s.activist_id, ap.activist_id))))
  WHERE postgraphql.current_user_has_community_participation(c.id)
  GROUP BY a.id, c.id;
}
  end
end
