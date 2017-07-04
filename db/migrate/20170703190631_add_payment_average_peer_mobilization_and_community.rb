class AddPaymentAveragePeerMobilizationAndCommunity < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function postgraphql.total_avg_donations_by_community(com_id integer) returns double precision
    language sql as $$
        select avg(d.payable_amount)
                from postgraphql.donations d where d.community_id = com_id
                and d.transaction_status = 'paid'
    $$;

create or replace function postgraphql.total_avg_donations_by_community_interval(com_id integer, timeinterval interval) returns double precision
    language sql as $$
        select avg(d.payable_amount)
                from postgraphql.donations d where d.community_id = com_id
                and d.transaction_status = 'paid'
                and d.payment_date > CURRENT_TIMESTAMP - timeinterval
    $$;

create or replace function postgraphql.total_avg_donations_by_mobilization(mob_id integer) returns double precision
    language sql as $$
        select avg(d.payable_amount)
                from postgraphql.donations d where d.mobilization_id = mob_id
                and d.transaction_status = 'paid'
    $$;

create or replace function postgraphql.total_avg_donations_by_mobilization_interval(mob_id integer, timeinterval interval) returns double precision
    language sql as $$
        select avg(d.payable_amount)
                from postgraphql.donations d where d.mobilization_id = mob_id
                and d.transaction_status = 'paid'
                and d.payment_date > CURRENT_TIMESTAMP - timeinterval
    $$;
}
  end

  def down
    execute %Q{
drop function postgraphql.total_avg_donations_by_community(com_id integer);
drop function postgraphql.total_avg_donations_by_community_interval(com_id integer, timeinterval integer);

drop function postgraphql.total_avg_donations_by_mobilization(mob_id integer);
drop function postgraphql.total_avg_donations_by_mobilization_interval(mob_id integer, timeinterval integer);
}
  end
end
