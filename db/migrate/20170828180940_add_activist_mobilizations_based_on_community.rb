class AddActivistMobilizationsBasedOnCommunity < ActiveRecord::Migration
  def up
    execute %Q{
create or replace view postgraphql.activist_mobilizations as
    select
        ma.activist_id,
        m.*
    from mobilization_activists ma
        join mobilizations m on m.id = ma.mobilization_id
        where postgraphql.current_user_has_community_participation(m.community_id);
grant select on postgraphql.activist_mobilizations to common_user, admin;
comment on view postgraphql.activist_mobilizations is 'show the mobilizations that activists participate'
}
  end

  def down
    execute %Q{
drop function postgraphql.activist_mobilizations
}
  end
end
