class AdjustMetricsFuncNames < ActiveRecord::Migration
  def change
    execute %Q{
alter function postgraphql.total_count_donations_from_community(com_id integer, status text, timeinterval interval)
  rename to total_count_donations_from_community_interval;
alter function postgraphql.total_count_donations_from_mobilization(mod_id integer, status text, timeinterval interval)
  rename to total_count_donations_from_mobilization_interval;
alter function postgraphql.total_count_subscription_donations_from_community(com_id integer, status text, timeinterval interval)
  rename to total_count_subscription_donations_from_community_interval;
alter function postgraphql.total_count_subscription_donations_from_mobilization(mob_id integer, status text, timeinterval interval)
  rename to total_count_subscription_donations_from_mobilization_interval;
alter function postgraphql.total_count_uniq_donations_from_community(com_id integer, status text, timeinterval interval)
  rename to total_count_uniq_donations_from_community_interval;
alter function postgraphql.total_count_uniq_donations_from_mobilization(mob_id integer, status text, timeinterval interval)
  rename to total_count_uniq_donations_from_mobilization_interval;
alter function postgraphql.total_sum_donations_from_community(com_id integer, status text, timeinterval interval)
  rename to total_sum_donations_from_community_interval;
alter function postgraphql.total_sum_donations_from_mobilization(mob_id integer, status text, timeinterval interval)
  rename to total_sum_donations_from_mobilization_interval;
alter function postgraphql.total_sum_subscription_donations_from_community(com_id integer, status text, timeinterval interval)
  rename to total_sum_subscription_donations_from_community_interval;
alter function postgraphql.total_sum_subscription_donations_from_mobilization(mob_id integer, status text, timeinterval interval)
  rename to total_sum_subscription_donations_from_mobilization_interval;
alter function postgraphql.total_sum_uniq_donations_from_community(com_id integer, status text, timeinterval interval)
  rename to total_sum_uniq_donations_from_community_interval;
alter function postgraphql.total_sum_uniq_donations_from_mobilization(mob_id integer, status text, timeinterval interval)
  rename to total_sum_uniq_donations_from_mobilization_interval;
alter function postgraphql.total_uniq_activists_by_kind_and_community(kind_name text, com_id integer, timeinterval interval)
  rename to total_uniq_activists_by_kind_and_community_interval;
alter function postgraphql.total_uniq_activists_by_kind_and_mobilization(kind_name text, mob_id integer, timeinterval interval)
  rename to total_uniq_activists_by_kind_and_mobilization_interval;
alter function postgraphql.total_unique_activists_by_community(com_id integer, timeinterval interval)
  rename to total_unique_activists_by_community_interval;
alter function postgraphql.total_unique_activists_by_mobilization(mob_id integer, timeinterval interval)
  rename to total_unique_activists_by_mobilization_interval;

alter function postgraphql.total_count_donations_from_community(com_id integer, status text) immutable;
alter function postgraphql.total_count_donations_from_community_interval(com_id integer, status text, timeinterval interval) immutable;
alter function postgraphql.total_count_donations_from_mobilization(mob_id integer, status text) immutable;
alter function postgraphql.total_count_donations_from_mobilization_interval(mod_id integer, status text, timeinterval interval) immutable;
alter function postgraphql.total_count_subscription_donations_from_community(com_id integer, status text) immutable;
alter function postgraphql.total_count_subscription_donations_from_community_interval(com_id integer, status text, timeinterval interval) immutable;
alter function postgraphql.total_count_subscription_donations_from_mobilization(mob_id integer, status text) immutable;
alter function postgraphql.total_count_subscription_donations_from_mobilization_interval(mob_id integer, status text, timeinterval interval) immutable;
alter function postgraphql.total_count_uniq_donations_from_community(com_id integer, status text) immutable;
alter function postgraphql.total_count_uniq_donations_from_community_interval(com_id integer, status text, timeinterval interval) immutable;
alter function postgraphql.total_count_uniq_donations_from_mobilization(mob_id integer, status text) immutable;
alter function postgraphql.total_count_uniq_donations_from_mobilization_interval(mob_id integer, status text, timeinterval interval) immutable;
alter function postgraphql.total_sum_donations_from_community(com_id integer, status text) immutable;
alter function postgraphql.total_sum_donations_from_community_interval(com_id integer, status text, timeinterval interval) immutable;
alter function postgraphql.total_sum_donations_from_mobilization(mob_id integer, status text) immutable;
alter function postgraphql.total_sum_donations_from_mobilization_interval(mob_id integer, status text, timeinterval interval) immutable;
alter function postgraphql.total_sum_subscription_donations_from_community(com_id integer, status text) immutable;
alter function postgraphql.total_sum_subscription_donations_from_community_interval(com_id integer, status text, timeinterval interval) immutable;
alter function postgraphql.total_sum_subscription_donations_from_mobilization(mob_id integer, status text) immutable;
alter function postgraphql.total_sum_subscription_donations_from_mobilization_interval(mob_id integer, status text, timeinterval interval) immutable;
alter function postgraphql.total_sum_uniq_donations_from_community(com_id integer, status text) immutable;
alter function postgraphql.total_sum_uniq_donations_from_community_interval(com_id integer, status text, timeinterval interval) immutable;
alter function postgraphql.total_sum_uniq_donations_from_mobilization(mob_id integer, status text) immutable;
alter function postgraphql.total_sum_uniq_donations_from_mobilization_interval(mob_id integer, status text, timeinterval interval) immutable;
alter function postgraphql.total_uniq_activists_by_kind_and_community(kind_name text, com_id integer) immutable;
alter function postgraphql.total_uniq_activists_by_kind_and_community_interval(kind_name text, com_id integer, timeinterval interval) immutable;
alter function postgraphql.total_uniq_activists_by_kind_and_mobilization(kind_name text, mob_id integer) immutable;
alter function postgraphql.total_uniq_activists_by_kind_and_mobilization_interval(kind_name text, mob_id integer, timeinterval interval) immutable;
alter function postgraphql.total_unique_activists_by_community(com_id integer) immutable;
alter function postgraphql.total_unique_activists_by_community_interval(com_id integer, timeinterval interval) immutable;
alter function postgraphql.total_unique_activists_by_mobilization(mob_id integer) immutable;
alter function postgraphql.total_unique_activists_by_mobilization_interval(mob_id integer, timeinterval interval) immutable;
}
  end
end
