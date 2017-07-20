class AddCommunityTags < ActiveRecord::Migration
  def up
    add_index :taggings, [:taggable_id, :taggable_type]
    execute %Q{
create or replace view public.community_tags as
    select
        at.community_id,
        tag.name as tag_complete_name,
        (regexp_split_to_array(tag.name, '\_'))[1] as tag_from,
        (regexp_split_to_array(tag.name, '\_'))[2] as tag_name,
        count(distinct at.activist_id) as total_activists
        from public.activist_tags at
            join public.taggings tgs on tgs.taggable_type = 'ActivistTag'
                and tgs.taggable_id = at.id
            join public.tags tag on tag.id = tgs.tag_id
        group by at.community_id, tag.name;

create or replace view postgraphql.community_tags as
    select
        *
    from public.community_tags
        where postgraphql.current_user_has_community_participation(community_id);

grant select on public.community_tags to common_user, admin;
grant select on postgraphql.community_tags to common_user, admin;
}
  end

  def down
    remove_index :taggings, [:taggable_id, :taggable_type]
    execute %Q{
drop view postgraphql.community_tags;
drop view public.community_tags;
}
  end
end
