class AdjustToGetMoreStatsOverDonationOnWidgets < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION postgraphql.get_widget_donation_stats(widget_id integer)
 RETURNS json
 LANGUAGE sql
 STABLE
AS $function$
        select
            json_build_object(
            'pledged', sum(d.amount / 100),
            'widget_id', w.id,
            'goal', w.goal,
            'progress', (sum(d.amount / 100) / w.goal) * 100,
            'total_donations', (count(distinct d.id)),
            'total_donators', (count(distinct d.activist_id))
            )
        from widgets w
            join donations d on d.widget_id = w.id
            where w.id = $1 and
              d.transaction_status = 'paid'
            group by w.id;
    $function$
;
grant execute on function postgraphql.get_widget_donation_stats(widget_id integer) to anonymous;
grant select on widgets to anonymous;
grant select on donations to anonymous;
}
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION postgraphql.get_widget_donation_stats(widget_id integer)
 RETURNS json
 LANGUAGE sql
 STABLE
AS $function$
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
    $function$
;
}
  end
end
