class TotalUniqueActivistsByKindOnCommunity < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function postgraphql.total_uniq_activists_by_kind_and_community(kind_name text, com_id integer) returns bigint
    language sql as $$
        select
            count(distinct activist_id) as total
        from postgraphql.participations
            where community_id = com_id
                and participate_kind = kind_name
    $$;


create or replace function postgraphql.total_uniq_activists_by_kind_and_community(kind_name text, com_id integer, timeinterval interval) returns bigint
    language sql as $$
        select
            count(distinct activist_id) as total
        from postgraphql.participations
            where community_id = com_id
                and participate_kind = kind_name
                and participate_at > CURRENT_TIMESTAMP - timeinterval;
    $$;

create or replace function postgraphql.total_uniq_activists_by_kind_and_mobilization(kind_name text, mob_id integer) returns bigint
    language sql as $$
        select
            count(distinct activist_id) as total
        from postgraphql.participations
            where mobilization_id = mob_id
                and participate_kind = kind_name
    $$;


create or replace function postgraphql.total_uniq_activists_by_kind_and_mobilization(kind_name text, mob_id integer, timeinterval interval) returns bigint
    language sql as $$
        select
            count(distinct activist_id) as total
        from postgraphql.participations
            where mobilization_id = mob_id
                and participate_kind = kind_name
                and participate_at > CURRENT_TIMESTAMP - timeinterval;
    $$;
}
  end

  def down
    execute %Q{
drop function postgraphql.total_uniq_activists_by_kind_and_community(kind_name text, com_id integer);
drop function postgraphql.total_uniq_activists_by_kind_and_community(kind_name text, com_id integer, timeinterval interval);
drop function postgraphql.total_uniq_activists_by_kind_and_mobilization(kind_name text, mob_id integer);
drop function postgraphql.total_uniq_activists_by_kind_and_mobilization(kind_name text, mob_id integer, timeinterval interval);
}
  end
end
