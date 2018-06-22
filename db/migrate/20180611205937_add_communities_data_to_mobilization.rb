class AddCommunitiesDataToMobilization < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function postgraphql.mobilizations_community (m postgraphql.mobilizations)
returns postgraphql.communities as $$
    select c.*
    from postgraphql.communities c
    where c.id = m.community_id
$$ language sql stable;
}
  end

  def down
    execute %Q{
drop function postgraphql.mobilizations_community(m postgraphql.mobilizations);
}
  end
end
