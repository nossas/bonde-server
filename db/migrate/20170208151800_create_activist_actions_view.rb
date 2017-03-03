class CreateActivistActionsView < ActiveRecord::Migration
  def up
    execute %Q{
create or replace view activist_actions as
select *
    from (
    (select
        'form_entries' as action,
        w.id as widget_id,
        m.id as mobilization_id,
        m.community_id as community_id,
        fe.activist_id as activist_id,
        fe.created_at as action_created_date,
        a.created_at as activist_created_at,
        a.email as activist_email
    from form_entries fe
        join activists a on a.id = fe.activist_id
        join widgets w on w.id = fe.widget_id
        join blocks b on b.id = w.block_id
        join mobilizations m on m.id = b.mobilization_id)
    union all
    (select
        'activist_pressures' as action,
        w.id as widget_id,
        m.id as mobilization_id,
        m.community_id as community_id,
        ap.activist_id as activist_id,
        ap.created_at as action_created_date,
        a.created_at as activist_created_at,
        a.email as activist_email
    from activist_pressures ap
        join activists a on a.id = ap.activist_id
        join widgets w on w.id = ap.widget_id
        join blocks b on b.id = w.block_id
        join mobilizations m on m.id = b.mobilization_id)
    union all
    (select
        'donation' as action,
        w.id as widget_id,
        m.id as mobilization_id,
        m.community_id as community_id,
        d.activist_id as activist_id,
        d.created_at as action_created_date,
        a.created_at as activist_created_at,
        a.email as activist_email
    from donations d
        join activists a on a.id = d.activist_id
        join widgets w on w.id = d.widget_id
        join blocks b on b.id = w.block_id
        join mobilizations m on m.id = b.mobilization_id)
    ) as t;
}
  end

  def down
    execute %Q{drop view activist_actions;}
  end
end
