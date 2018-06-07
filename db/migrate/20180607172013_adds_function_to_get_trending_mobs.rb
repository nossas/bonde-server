class AddsFunctionToGetTrendingMobs < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION postgraphql.mobilizations(days integer)
RETURNS json AS $$
DECLARE
    _result json;
BEGIN
    if current_role = 'anonymous' then
        raise 'permission_denied';
    end if;

    select json_agg(row_to_json(t.*)) from (select
        c.name as community_name,
        m.name,
        m.goal,
        m.facebook_share_image,
        m.created_at::timestamp as created_at,
        m.updated_at::timestamp as updated_at,
        count(m.id) as score
        -- m.*
    from
        activist_actions aa
        left join mobilizations m on aa.mobilization_id = m.id
        left join communities c on m.community_id = c.id
    where
        -- aa.action_created_date >= now()::date - interval '90days'
        aa.action_created_date >= now()::date - (days || 'days')::interval
    group by
        m.id,
        c.name
    order by
        score desc
    ) t
    into _result;

    return _result;
END
$$ LANGUAGE plpgsql;

grant execute on function postgraphql.mobilizations(days integer) to common_user, admin, postgraphql;
grant select on public.mobilizations to common_user, admin, postgraphql;
grant select on public.activist_actions to common_user, admin, postgraphql;
}
  end

  def down
    execute %Q{
drop function postgraphql.mobilizations(days integer);
}
  end
end
