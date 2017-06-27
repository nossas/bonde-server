class CreatePosgraphqlDonationsView < ActiveRecord::Migration
  def up
    execute %Q{
create or replace view postgraphql.donations as
    select
        d.id as donation_id,
        c.id as community_id,
        w.id as widget_id,
        m.id as mobilization_id,
        b.id as block_id,
        d.activist_id as activist_id,
        d.email as donation_email,
        d.amount / 100 as donation_amount,
        d.local_subscription_id as subscription_id,
        d.transaction_status as transaction_status,
        pd.payment_date as payment_date,
        pd.payable_date as payable_date,
        pd.payable_value as payable_amount,
        pd.payable_status as payable_status,
        s.status as subscription_status
        from public.donations d
            join public.widgets w on w.id = d.widget_id
            join public.blocks b on b.id = w.block_id
            join public.mobilizations m on m.id = b.mobilization_id
            join public.communities c on c.id = m.community_id
            left join subscriptions s on s.id = d.local_subscription_id
            left join public.payable_details pd on pd.donation_id = d.id
        where d.transaction_id is not null and c.id in (select community_id from postgraphql.community_user_roles);

grant select on public.donations to common_user, admin;
grant select on postgraphql.donations to common_user, admin;

}
  end

  def down
    execute %Q{
drop view postgraphql.donations;
}
  end
end
