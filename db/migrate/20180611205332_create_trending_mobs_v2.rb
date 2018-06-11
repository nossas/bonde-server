class CreateTrendingMobsV2 < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function postgraphql.trending_mobilizations(days integer)
returns setof postgraphql.mobilizations as $$
select m.*
from postgraphql.mobilizations m
left join lateral (
    select count(1)
    from public.activist_actions aa
        where aa.mobilization_id  = m.id
            and aa.action_created_date >= now()::date - (days || ' days')::interval
) as score on true
order by score desc;
$$ language sql stable;

grant select on public.activist_actions to common_user, admin, postgraphql;
}
  end

  def down
    execute %Q{
drop function postgraphql.trending_mobilizations(days integer);
}
  end
end
