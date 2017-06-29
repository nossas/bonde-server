class AddActivistParticipations < ActiveRecord::Migration
  def change
    execute %Q{
create or replace view public.activist_participations as
select
    c.id as community_id,
    m.id as mobilization_id,
    w.id as widget_id,
    a.id as activist_id,
    a.email,
    coalesce(fe.created_at, d.created_at, ap.created_at, s.created_at) as participate_at,
    case
        when fe.id is not null then 'form_entry'
        when d.id is not null then 'donation'
        when ap.id is not null then 'activist_pressure'
        when s.id is not null then 'subscription'
    end as participate_kind,
    coalesce(fe.id, d.id, ap.id, s.id) as participate_id
from communities c
    join mobilizations m on m.community_id = c.id
    left join blocks b on b.mobilization_id = m.id
    left join widgets w on w.block_id = b.id
    left join form_entries fe on fe.widget_id = w.id
    left join donations d on d.widget_id = w.id and not d.subscription
    left join subscriptions s on s.widget_id = w.id
    left join activist_pressures ap on ap.widget_id = w.id
    join activists a on a.id = coalesce(fe.activist_id, d.activist_id, s.activist_id, ap.activist_id)
group by c.id, m.id, w.id, a.id, fe.id, s.id, ap.id, d.id, fe.created_at, s.created_at, ap.created_at, d.created_at;
}
  end
end
