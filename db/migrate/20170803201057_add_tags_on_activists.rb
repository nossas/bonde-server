class AddTagsOnActivists < ActiveRecord::Migration
  def change
    execute %Q{
CREATE OR REPLACE VIEW postgraphql.activists AS
SELECT c.id AS community_id,
    a.id,
    a.name,
    a.email,
    a.phone,
    a.document_number,
    a.created_at,
    row_to_json(a.*) AS data,
    json_agg(DISTINCT m.*) AS mobilizations,
    (
        select 
            jsonb_build_array(jsonb_build_object('tag_complete_name', tag.name,
            'tag_from', (regexp_split_to_array((tag.name)::text, '_'::text))[1],
            'tag_name', (regexp_split_to_array((tag.name)::text, '_'::text))[2],
            'activist_tag_id', atg.id))
            from public.activist_tags atg
                join public.taggings tgs on tgs.taggable_type = 'ActivistTag'
                    and tgs.taggable_id = atg.id
                join public.tags tag on tag.id = tgs.tag_id
                where atg.activist_id = a.id
                    and atg.community_id = c.id
    ) AS tags
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
