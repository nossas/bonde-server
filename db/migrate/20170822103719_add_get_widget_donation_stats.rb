class AddGetWidgetDonationStats < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function postgraphql.get_widget_donation_stats(widget_id integer) returns json
    language sql
    as $$
        select
            json_build_object(
            'pledged', sum(d.amount / 100),
            'widget_id', w.id,
            'goal', w.goal,
            'progress', (sum(d.amount / 100) / w.goal) * 100)
        from widgets w
            join donations d on d.widget_id = w.id
            where w.id = $1 and
              d.transaction_status = 'paid'
            group by w.id;
    $$;
COMMENT ON FUNCTION postgraphql.get_widget_donation_stats(widget_id integer) IS 'Returns a json with pledged, progress and goal from widget';
}
  end

  def down
    execute %Q{
drop function postgraphql.get_widget_donation_stats(widget_id integer);
}
  end
end
