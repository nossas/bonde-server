class AddSubscriptionReports < ActiveRecord::Migration
  def up
    execute %Q{
create or replace view public.subscription_reports as
    select
        s.community_id,
        a.name as "Nome do doador",
        a.email as "Email do doador",
        (s.amount / 100.0)::decimal(13, 2) as "Valor de doação",
        s.status as "Status de assinatura",
        s.payment_method as "Forma de doação (boleto/cartão)",
        s.id as "ID da assinatura",
        s.created_at as "Data de início da assinatura",
        (case when s.status = 'canceled' then ct.created_at else null end) as "Data do cancelamento da assinatura",
        (case when s.status = 'unpaid' then ut.created_at else null end) as "Data do primeiro",
        'https://app.bonde.org/subscriptions/'||s.id||'/edit?token='||s.token as "Link de alteração da assinatura"
    from subscriptions s
    left join lateral (
        select * from subscription_transitions st
            where st.subscription_id = s.id
                and st.to_state = 'canceled'
                order by created_at desc
                limit 1
    ) as ct on true
    left join lateral (
        select * from subscription_transitions st
            where st.subscription_id = s.id
                and st.to_state = 'unpaid'
                order by created_at asc
                limit 1
    ) as ut on true
    join activists a on a.id = s.activist_id;
}
  end

  def down
    execute %Q{
drop view public.subscription_reports;
}
  end
end
