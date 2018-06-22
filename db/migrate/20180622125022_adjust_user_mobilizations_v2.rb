class AdjustUserMobilizationsV2 < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE VIEW postgraphql.user_mobilizations AS
 SELECT
    m.*
   FROM (postgraphql.mobilizations m
     JOIN public.community_users cou ON ((cou.community_id = m.community_id)))
   WHERE cou.user_id = postgraphql.current_user_id();

GRANT SELECT ON postgraphql.user_mobilizations TO common_user, admin;

CREATE OR REPLACE FUNCTION  postgraphql.user_mobilizations_community (m postgraphql.user_mobilizations)
returns postgraphql.communities as $$
    select c.*
    from postgraphql.communities c
    where c.id = m.community_id
$$ language sql stable;

GRANT EXECUTE ON function postgraphql.user_mobilizations_community(m postgraphql.user_mobilizations) to common_user, admin;
}
  end

  def down
    execute %Q{
DROP FUNCTION postgraphql.user_mobilizations_community(m postgraphql.user_mobilizations);
}
  end
end
