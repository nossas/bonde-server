class ChangeViewCommunitiesToPublicAccessInV2 < ActiveRecord::Migration
  def up
    execute %Q{
DROP view postgraphql.communities;

CREATE OR REPLACE VIEW "postgraphql"."communities" AS
 SELECT com.id,
    com.name,
    com.city,
    com.description,
    com.created_at,
    com.updated_at,
    com.image,
    com.fb_link,
    com.twitter_link
   FROM communities com;

GRANT SELECT ON postgraphql.communities TO common_user, admin, postgraphql;
}
  end

  def down
    execute %Q{
drop view postgraphql.communities;
}
  end
end
