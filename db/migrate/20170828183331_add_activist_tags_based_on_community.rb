class AddActivistTagsBasedOnCommunity < ActiveRecord::Migration
  def up
    execute %Q{
create or replace view postgraphql.activist_tags as 
    SELECT at.community_id,
        at.activist_id,
        tag.name AS tag_complete_name,
        (regexp_split_to_array((tag.name)::text, '_'::text))[1] AS tag_from,
        replace((regexp_split_to_array((tag.name)::text, '_'::text))[2], '-', ' ') AS tag_name
       FROM ((activist_tags at
         JOIN taggings tgs ON ((((tgs.taggable_type)::text = 'ActivistTag'::text) AND (tgs.taggable_id = at.id))))
         JOIN tags tag ON ((tag.id = tgs.tag_id)))
        where postgraphql.current_user_has_community_participation(at.community_id);
grant select on postgraphql.activist_tags to admin, common_user;
}
  end

  def down
    execute %Q{
drop view postgraphql.activist_tags;
}
  end
end
