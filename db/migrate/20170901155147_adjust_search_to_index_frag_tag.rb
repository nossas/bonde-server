class AdjustSearchToIndexFragTag < ActiveRecord::Migration
  def change
    execute %Q{
CREATE OR REPLACE FUNCTION postgraphql.search_activists_on_community(query text, ctx_community_id integer)
 RETURNS SETOF postgraphql.activists
 LANGUAGE sql
 STABLE
AS $function$
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
                                              to_tsvector('portuguese', (vec->>'tag_name')::text), 'B'
                                          )||setweight(
                                              to_tsvector('portuguese', vec->>'activist_name'), 'B'
                                          )||setweight(
                                              to_tsvector('portuguese', vec->>'activist_email'), 'C'
                                          ))::tsvector @@ plainto_tsquery('portuguese', query)
                            ) as found
                        ) as si_r on found
                        join lateral (
                             SELECT pa.*
                             FROM postgraphql.activists pa
                              WHERE pa.community_id = si.community_id
                                and pa.id = si.activist_id
                        ) as act on true
        $function$;

}
  end
end
