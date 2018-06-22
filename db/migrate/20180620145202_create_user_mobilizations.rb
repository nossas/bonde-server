class CreateUserMobilizations < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE VIEW postgraphql.user_mobilizations AS
 SELECT
    m.*
   FROM (public.mobilizations m
     JOIN public.community_users cou ON ((cou.community_id = m.community_id)))
   WHERE cou.user_id = postgraphql.current_user_id();

GRANT SELECT ON public.mobilizations TO common_user, admin;
}
  end

  def down
    execute %Q{
drop view postgraphql.user_mobilizations;
}
  end
end
