class TotalAndSumOnDonationsByMobilization < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function postgraphql.total_sum_donations_from_mobilization(mob_id integer, status text) returns double precision
    language sql as $$
        select coalesce((select sum(d.payable_amount) 
            from postgraphql.donations d
                where d.mobilization_id = mob_id
                    and d.transaction_status = status), 0);
    $$;

create or replace function postgraphql.total_sum_donations_from_mobilization(mob_id integer, status text, timeinterval interval) returns double precision
    language sql as $$
        select coalesce((select sum(d.payable_amount) 
            from postgraphql.donations d
                where d.mobilization_id = mob_id
                    and d.transaction_status = status
                    and d.payment_date > CURRENT_TIMESTAMP - timeinterval), 0);
    $$;

create or replace function postgraphql.total_count_donations_from_mobilization(mob_id integer, status text) returns bigint
    language sql as $$
        select coalesce((select count(1) 
            from postgraphql.donations d
                where d.mobilization_id = mob_id
                    and d.transaction_status = status), 0);
    $$;

create or replace function postgraphql.total_count_donations_from_mobilization(mod_id integer, status text, timeinterval interval) returns bigint
    language sql as $$
        select coalesce((select count(1) 
            from postgraphql.donations d
                where d.mobilization_id = mod_id
                    and d.transaction_status = status
                    and d.payment_date > CURRENT_TIMESTAMP - timeinterval), 0);
    $$;



create or replace function postgraphql.total_sum_uniq_donations_from_mobilization(mob_id integer, status text) returns double precision
    language sql as $$
        select coalesce((select sum(d.payable_amount) 
            from postgraphql.donations d
                where d.mobilization_id = mob_id
                    and d.subscription_id is null
                    and d.transaction_status = status), 0);
    $$;

create or replace function postgraphql.total_sum_uniq_donations_from_mobilization(mob_id integer, status text, timeinterval interval) returns double precision
    language sql as $$
        select coalesce((select sum(d.payable_amount) 
            from postgraphql.donations d
                where d.mobilization_id = mob_id
                    and d.transaction_status = status
                    and d.subscription_id is null
                    and d.payment_date > CURRENT_TIMESTAMP - timeinterval), 0);
    $$;

create or replace function postgraphql.total_count_uniq_donations_from_mobilization(mob_id integer, status text) returns bigint
    language sql as $$
        select coalesce((select count(1) 
            from postgraphql.donations d
                where d.mobilization_id = mob_id
                    and d.subscription_id is null
                    and d.transaction_status = status), 0);
    $$;

create or replace function postgraphql.total_count_uniq_donations_from_mobilization(mob_id integer, status text, timeinterval interval) returns bigint
    language sql as $$
        select coalesce((select count(1) 
            from postgraphql.donations d
                where d.mobilization_id = mob_id
                    and d.transaction_status = status
                    and d.subscription_id is null
                    and d.payment_date > CURRENT_TIMESTAMP - timeinterval), 0);
    $$;

create or replace function postgraphql.total_sum_subscription_donations_from_mobilization(mob_id integer, status text) returns double precision
    language sql as $$
        select coalesce((select sum(d.payable_amount) 
            from postgraphql.donations d
                where d.mobilization_id = mob_id
                    and d.subscription_id is not null
                    and d.transaction_status = status), 0);
    $$;

create or replace function postgraphql.total_sum_subscription_donations_from_mobilization(mob_id integer, status text, timeinterval interval) returns double precision
    language sql as $$
        select coalesce((select sum(d.payable_amount) 
            from postgraphql.donations d
                where d.mobilization_id = mob_id
                    and d.transaction_status = status
                    and d.subscription_id is not null
                    and d.payment_date > CURRENT_TIMESTAMP - timeinterval), 0);
    $$;

create or replace function postgraphql.total_count_subscription_donations_from_mobilization(mob_id integer, status text) returns bigint
    language sql as $$
        select coalesce((select count(1) 
            from postgraphql.donations d
                where d.mobilization_id = mob_id
                    and d.subscription_id is not null
                    and d.transaction_status = status), 0);
    $$;

create or replace function postgraphql.total_count_subscription_donations_from_mobilization(mob_id integer, status text, timeinterval interval) returns bigint
    language sql as $$
        select coalesce((select count(1) 
            from postgraphql.donations d
                where d.mobilization_id = mob_id
                    and d.transaction_status = status
                    and d.subscription_id is not null
                    and d.payment_date > CURRENT_TIMESTAMP - timeinterval), 0);
    $$;

}
  end

  def down
    execute %Q{
drop function postgraphql.total_sum_donations_from_mobilization(mob_id integer, status text);
drop function postgraphql.total_sum_donations_from_mobilization(mob_id integer, status text, timeinterval interval);
drop function postgraphql.total_count_donations_from_mobilization(mob_id integer, status text);
drop function postgraphql.total_count_donations_from_mobilization(mob_id integer, status text, timeinterval interval);
drop function postgraphql.total_sum_uniq_donations_from_mobilization(mob_id integer, status text);
drop function postgraphql.total_sum_uniq_donations_from_mobilization(mob_id integer, status text, timeinterval interval);
drop function postgraphql.total_count_uniq_donations_from_mobilization(mob_id integer, status text);
drop function postgraphql.total_count_uniq_donations_from_mobilization(mob_id integer, status text, timeinterval interval);
drop function postgraphql.total_sum_subscription_donations_from_mobilization(mob_id integer, status text);
drop function postgraphql.total_sum_subscription_donations_from_mobilization(mob_id integer, status text, timeinterval interval);
drop function postgraphql.total_count_subscription_donations_from_mobilization(mob_id integer, status text);
drop function postgraphql.total_count_subscription_donations_from_mobilization(mob_id integer, status text, timeinterval interval);

}
  end
end
