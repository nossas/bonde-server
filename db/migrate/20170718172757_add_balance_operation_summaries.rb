class AddBalanceOperationSummaries < ActiveRecord::Migration
  def up
    execute %Q{
create or replace view public.balance_operation_summaries as
    select
        bo.id,
        bo.recipient_id,
        r.community_id,
        bo.gateway_data ->> 'type' as operation_type,
        bo.gateway_data ->> 'object' as operation_object,
        bo.gateway_data ->> 'status' as operation_status,
        (bo.gateway_data ->> 'amount')::numeric / 100.0 as operation_amount,
        (bo.gateway_data ->> 'balance_amount')::numeric / 100.0 as balance_amount_at_moment,
        (bo.gateway_data ->> 'fee')::numeric / 100.0 as operation_fee,
        (bo.gateway_data ->> 'date_created')::timestamp as operation_created_at,
        (bo.gateway_data -> 'movement_object' ->> 'id') as movement_object_id,
        (bo.gateway_data -> 'movement_object' ->> 'type') as movement_object_type,
        (bo.gateway_data -> 'movement_object' ->> 'status') as movement_object_status,
        (bo.gateway_data -> 'movement_object' ->> 'object') as movement_object_object,
        (bo.gateway_data -> 'movement_object' ->> 'amount')::numeric / 100.0 as movement_object_amount,
        (bo.gateway_data -> 'movement_object' ->> 'fee')::numeric / 100.0 as movement_object_fee,
        (bo.gateway_data -> 'movement_object' ->> 'transaction_id') as movement_object_transaction_id,
        (bo.gateway_data -> 'movement_object' ->> 'payment_method') as movement_object_payment_method,
        (bo.gateway_data -> 'movement_object') as movement_object
        from balance_operations bo
            join recipients r on r.id = bo.recipient_id
        order by (bo.gateway_data ->> 'date_created')::timestamp DESC;

create or replace view postgraphql.balance_operations as
    select bos.*
        from balance_operation_summaries bos
        where postgraphql.current_user_has_community_participation(bos.community_id);

grant select on public.balance_operation_summaries to common_user, admin;
grant select on postgraphql.balance_operations to common_user, admin;
}
  end

  def down
    execute %Q{
DROP VIEW postgraphql.balance_operations;
DROP VIEW public.balance_operation_summaries;
}
  end
end
