class AddTotalSumTransferOperationsFromCommunity < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function postgraphql.total_sum_transfer_operations_from_community(community_id integer)
    returns decimal
    language sql
    as $$
         WITH current_communities_access AS (
             SELECT DISTINCT(cu.community_id)
               FROM community_users cu
              WHERE ((cu.user_id = postgraphql.current_user_id()) OR ("current_user"() = 'admin'::name))
            ) select sum(bos.operation_amount) 
            from public.balance_operation_summaries bos
            where bos.operation_type = 'transfer' 
            and bos.community_id = $1 and (bos.community_id IN (
            SELECT current_communities_access.community_id FROM current_communities_access));
    $$;
comment on function postgraphql.total_sum_transfer_operations_from_community(community_id integer) is 'Get total sum of all transfers to community';
grant select on public.balance_operation_summaries to common_user, admin;
grant select on public.balance_operations to common_user, admin;
grant execute on function postgraphql.total_sum_transfer_operations_from_community(integer) to common_user, admin;
}
  end

  def down
    execute %Q{
drop function postgraphql.total_sum_transfer_operations_from_community(community_id integer);
}
  end
end
