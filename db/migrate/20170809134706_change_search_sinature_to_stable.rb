class ChangeSearchSinatureToStable < ActiveRecord::Migration
  def change
    execute %Q{
create or replace function postgraphql.search_activists_on_community(query text, ctx_community_id integer)
    returns setof postgraphql.activists 
    language sql
    stable
    as $$
        with search_index as (
              select
                  atg.community_id,
                  atg.activist_id,
                  json_agg(json_build_object(
                    'tag_name', tag.name,
                    'activist_name', a.name,
                    'activist_email', a.email
                  )) package_search_vector
                  from public.activist_tags atg
                      join public.taggings tgs on tgs.taggable_type = 'ActivistTag'
                          and tgs.taggable_id = atg.id
                      join public.tags tag on tag.id = tgs.tag_id
                      join public.activists a on a.id = atg.activist_id
                      where atg.community_id = ctx_community_id
                    group by atg.activist_id, atg.community_id, a.id
              ) select
                    act.*
                    from search_index si
                        join lateral (
                            select exists (
                                select
                                    true
                                from json_array_elements(si.package_search_vector)  as vec
                                    where (setweight(
                                              to_tsvector('portuguese', replace((regexp_split_to_array((vec->>'tag_name')::text, '_'::text))[2], '-', ' ')), 'A'
                                          )||setweight(
                                              to_tsvector('portuguese', vec->>'activist_name'), 'B'
                                          )||setweight(
                                              to_tsvector('portuguese', vec->>'activist_email'), 'C'
                                          ))::tsvector @@ plainto_tsquery('portuguese', query)
                            ) as found
                        ) as si_r on found
                        join lateral (
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
                                 LEFT JOIN public.donations d ON (((d.widget_id = w.id) AND (NOT d.subscription))))
                                 LEFT JOIN subscriptions s ON ((s.widget_id = w.id)))
                                 LEFT JOIN activist_pressures ap ON ((ap.widget_id = w.id)))
                                 JOIN public.activists a ON ((a.id = COALESCE(fe.activist_id, d.activist_id, s.activist_id, ap.activist_id))))
                              WHERE c.id = si.community_id
                                and a.id = si.activist_id
                              GROUP BY a.id, c.id
                        ) as act on true
                        where postgraphql.current_user_has_community_participation(ctx_community_id)
        $$;
}
  end
end
