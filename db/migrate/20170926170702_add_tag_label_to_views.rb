class AddTagLabelToViews < ActiveRecord::Migration
  def change
    execute %Q{
CREATE OR REPLACE VIEW "public"."community_tags" AS 
 SELECT at.community_id,
    tag.name AS tag_complete_name,
    (regexp_split_to_array((tag.name)::text, '_'::text))[1] AS tag_from,
    (regexp_split_to_array((tag.name)::text, '_'::text))[2] AS tag_name,
    count(DISTINCT at.activist_id) AS total_activists,
    tag.label AS tag_label
   FROM ((activist_tags at
     JOIN taggings tgs ON ((((tgs.taggable_type)::text = 'ActivistTag'::text) AND (tgs.taggable_id = at.id))))
     JOIN tags tag ON ((tag.id = tgs.tag_id)))
  GROUP BY at.community_id, tag.name, tag.label;

CREATE OR REPLACE VIEW "postgraphql"."community_tags" AS 
 SELECT community_tags.community_id,
    community_tags.tag_complete_name,
    community_tags.tag_from,
    community_tags.tag_name,
    community_tags.total_activists,
    community_tags.tag_label
   FROM community_tags
  WHERE postgraphql.current_user_has_community_participation(community_tags.community_id);

CREATE OR REPLACE VIEW "postgraphql"."activist_tags" AS 
 SELECT at.community_id,
    at.activist_id,
    tag.name AS tag_complete_name,
    (regexp_split_to_array((tag.name)::text, '_'::text))[1] AS tag_from,
    replace((regexp_split_to_array((tag.name)::text, '_'::text))[2], '-'::text, ' '::text) AS tag_name,
    tag.label as tag_label
   FROM ((activist_tags at
     JOIN taggings tgs ON ((((tgs.taggable_type)::text = 'ActivistTag'::text) AND (tgs.taggable_id = at.id))))
     JOIN tags tag ON ((tag.id = tgs.tag_id)))
  WHERE postgraphql.current_user_has_community_participation(at.community_id);
}
  end
end
