class AddReceivingNotificationsFunc < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function public.receiving_unpaid_notifications(public.subscriptions)
returns boolean
language plpgsql
stable
as $$
    declare
        _last_paid_donation public.donations;
    begin
        select * from donations
            where local_subscription_id = $1.id
                and transaction_status = 'paid'
                order by created_at desc
                limit 1
        into _last_paid_donation;
        
        if _last_paid_donation.id is not null then
            return coalesce((
                select count(1) <= 2 
                    from notifications n
                    join notification_templates nt on nt.id = n.notification_template_id
                    where nt.label = 'unpaid_subscription'
                        and (n.template_vars->>'subscription_id')::integer = $1.id
                        and n.created_at >= _last_paid_donation.created_at
            ), true);
        else
            return (
                select count(1) <= 2 
                    from notifications n
                    join notification_templates nt on nt.id = n.notification_template_id
                    where nt.label = 'unpaid_subscription'
                        and (n.template_vars->>'subscription_id')::integer = $1.id
            );
        end if;
    end;
$$;
}
  end

  def down
    execute %Q{
drop function public.receiving_unpaid_notifications(public.subscriptions);
}
  end
end
