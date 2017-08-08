class AddSearchActivistsOnCommunity < ActiveRecord::Migration
  def change
    execute %Q{
    create EXTENSION unaccent;
grant select on public.activist_tags to common_user, admin;
grant select on public.taggings to common_user, admin;
grant select on public.tags to common_user, admin;

create or replace function postgraphql.search_activists_on_community(query text, ctx_com_id integer)
    returns setof postgraphql.activists
    language sql
    as $$
        with search_index as (
          select
              atg.community_id,
              atg.activist_id,
              (setweight(
                  to_tsvector('portuguese', replace((regexp_split_to_array((tag.name)::text, '_'::text))[2], '-', ' ')), 'A'
              )||setweight(
                  to_tsvector('portuguese', a.name), 'B'
              )||setweight(
                  to_tsvector('portuguese', a.email), 'C'
              ))::tsvector search_vector,
              (jsonb_build_object('tag_complete_name', tag.name,
              'tag_from', (regexp_split_to_array((tag.name)::text, '_'::text))[1],
              'tag_name', (regexp_split_to_array((tag.name)::text, '_'::text))[2]),
              'tag_parsed_name', replace((regexp_split_to_array((tag.name)::text, '_'::text))[2], '-', ' ')) as tag_data
              from public.activist_tags atg
                  join public.taggings tgs on tgs.taggable_type = 'ActivistTag'
                      and tgs.taggable_id = atg.id
                  join public.tags tag on tag.id = tgs.tag_id
                  join public.activists a on a.id = atg.activist_id
                  where atg.community_id = ctx_com_id
                group by atg.activist_id, atg.community_id, a.id, tag.name
          ), do_search as (
            select si.community_id, si.activist_id
                from search_index si
                where si.search_vector @@ plainto_tsquery('portuguese', unaccent(query))
                    and postgraphql.current_user_has_community_participation(si.community_id)
                    and si.community_id = ctx_com_id
                group by si.community_id, si.activist_id
                -- order by ts_rank(si.search_vector, plainto_tsquery('portuguese', unaccent(query))) desc
          ) select
                act.*
                from do_search ds
                    join postgraphql.activists act on act.id = ds.activist_id
                    where act.community_id = ctx_com_id
                        and act.id = ds.activist_id;
    $$;
}
  end
end
