class AddsScoreToUserMobilizations < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION postgraphql.user_mobilizations_score (m postgraphql.user_mobilizations)
returns BIGINT as $$
    select count(1)
    from public.activist_actions aa
        where aa.mobilization_id  = m.id
$$ language sql stable;

GRANT EXECUTE ON function postgraphql.user_mobilizations_score(m postgraphql.user_mobilizations) to common_user, admin;
}
  end

  def down
    execute %Q{
drop function postgraphql.user_mobilizations_score(m postgraphql.user_mobilizations);
}
  end
end
