class AddActivistsToPosgraphql < ActiveRecord::Migration
  def up
    execute %Q{
grant select on public.activists to admin, common_user;
grant select on public.communities to common_user, admin;
grant select on public.mobilizations to common_user, admin;
grant select on public.blocks to common_user, admin;
grant select on public.widgets to common_user, admin;
grant select on public.form_entries to common_user, admin;
grant select on public.subscriptions to common_user, admin;
grant select on public.activist_pressures to common_user, admin;

CREATE OR REPLACE VIEW "postgraphql"."activists" AS
 SELECT c.id AS community_id,
    a.id AS id,
    a.name,
    a.email,
    a.phone,
    a.document_number,
    a.created_at,
    row_to_json(a.*) as data
   FROM ((((((((communities c
     JOIN mobilizations m ON ((m.community_id = c.id)))
     LEFT JOIN blocks b ON ((b.mobilization_id = m.id)))
     LEFT JOIN widgets w ON ((w.block_id = b.id)))
     LEFT JOIN form_entries fe ON ((fe.widget_id = w.id)))
     LEFT JOIN donations d ON (((d.widget_id = w.id) AND (NOT d.subscription))))
     LEFT JOIN subscriptions s ON ((s.widget_id = w.id)))
     LEFT JOIN activist_pressures ap ON ((ap.widget_id = w.id)))
     JOIN activists a ON ((a.id = COALESCE(fe.activist_id, d.activist_id, s.activist_id, ap.activist_id))))
  where postgraphql.current_user_has_community_participation(c.id)
  GROUP BY a.id, c.id;
}
  end

  def down
    execute %Q{
drop view "postgraphql"."activists";
}
  end
end
