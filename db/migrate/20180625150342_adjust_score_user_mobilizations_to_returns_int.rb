class AdjustScoreUserMobilizationsToReturnsInt < ActiveRecord::Migration
  def up
    execute %Q{
drop function IF EXISTS postgraphql.user_mobilizations_score(m postgraphql.user_mobilizations);

CREATE OR REPLACE FUNCTION postgraphql.user_mobilizations_score (m postgraphql.user_mobilizations)
returns integer as $$
    select count(1)::INT
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
