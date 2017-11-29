class AdjustActivistsToUseFieldsFromProfileData < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE VIEW "postgraphql"."activists" AS 
 WITH current_communities_access AS (
         SELECT DISTINCT cu.community_id
           FROM community_users cu
          WHERE ((cu.user_id = postgraphql.current_user_id()) OR ("current_user"() = 'admin'::name))
        )
 SELECT ca.community_id,
    ca.activist_id as id,
    (ca.profile_data ->> 'name')::varchar as name,
    a.email,
    (ca.profile_data ->> 'phone')::varchar as phone,
    (ca.profile_data ->> 'document_number')::varchar as document_number,
    ca.created_at,
    ca.profile_data::json AS data,
    '{}'::json AS mobilizations,
    '{}'::jsonb AS tags
   FROM (community_activists ca
     JOIN activists a ON ((a.id = ca.activist_id)))
  WHERE (ca.community_id IN ( SELECT current_communities_access.community_id
           FROM current_communities_access));
}
  end

  def down
    execute %Q{
CREATE OR REPLACE VIEW "postgraphql"."activists" AS 
 WITH current_communities_access AS (
         SELECT DISTINCT cu.community_id
           FROM community_users cu
          WHERE ((cu.user_id = postgraphql.current_user_id()) OR ("current_user"() = 'admin'::name))
        )
 SELECT ca.community_id,
    a.id,
    a.name,
    a.email,
    a.phone,
    a.document_number,
    a.created_at,
    row_to_json(a.*) AS data,
    '{}'::json AS mobilizations,
    '{}'::jsonb AS tags
   FROM (community_activists ca
     JOIN activists a ON ((a.id = ca.activist_id)))
  WHERE (ca.community_id IN ( SELECT current_communities_access.community_id
           FROM current_communities_access))
  GROUP BY a.id, ca.community_id;
}
  end
end
