class AddReceivingNotificationToSubscriptionsReport < ActiveRecord::Migration
  def up
    execute %Q{
drop view public.subscription_reports;
CREATE OR REPLACE VIEW "public"."subscription_reports" AS 
 SELECT s.community_id,
    a.name AS "Nome do doador",
    a.email AS "Email do doador",
    (((s.amount)::numeric / 100.0))::numeric(13,2) AS "Valor de doação",
    s.status AS "Status de assinatura",
    s.payment_method AS "Forma de doação (boleto/cartão)",
    s.id AS "ID da assinatura",
    s.created_at AS "Data de início da assinatura",
        CASE
            WHEN ((s.status)::text = 'canceled'::text) THEN ct.created_at
            ELSE NULL::timestamp without time zone
        END AS "Data do cancelamento da assinatura",
        CASE
            WHEN ((s.status)::text = 'unpaid'::text) THEN
              (case when public.receiving_unpaid_notifications(s) then 'Sim' else 'Não' end)
            ELSE NULL
        END AS "recebendo notificações?",
    ((('https://app.bonde.org/subscriptions/'::text || s.id) || '/edit?token='::text) || s.token) AS "Link de alteração da assinatura"
   FROM (((subscriptions s
     JOIN activists a ON ((a.id = s.activist_id)))
     LEFT JOIN LATERAL ( SELECT st.id,
            st.to_state,
            st.metadata,
            st.sort_key,
            st.subscription_id,
            st.most_recent,
            st.created_at,
            st.updated_at
           FROM subscription_transitions st
          WHERE ((st.subscription_id = s.id) AND ((st.to_state)::text = 'canceled'::text))
          ORDER BY st.created_at DESC
         LIMIT 1) ct ON (true))
     LEFT JOIN LATERAL ( SELECT n.id,
            n.activist_id,
            n.notification_template_id,
            n.template_vars,
            n.created_at,
            n.updated_at,
            n.community_id,
            n.user_id,
            n.email,
            n.deliver_at,
            n.delivered_at
           FROM (notifications n
             JOIN notification_templates nt ON ((nt.id = n.notification_template_id)))
          WHERE ((nt.label = 'unpaid_subscription'::text) AND (((n.template_vars ->> 'subscription_id'::text))::integer = s.id))
          ORDER BY n.created_at DESC
         LIMIT 1) last_unpaid_notification ON (true));
}
  end

  def down
    execute %Q{
drop view public.subscription_reports;
CREATE OR REPLACE VIEW "public"."subscription_reports" AS 
 SELECT s.community_id,
    a.name AS "Nome do doador",
    a.email AS "Email do doador",
    (((s.amount)::numeric / 100.0))::numeric(13,2) AS "Valor de doação",
    s.status AS "Status de assinatura",
    s.payment_method AS "Forma de doação (boleto/cartão)",
    s.id AS "ID da assinatura",
    s.created_at AS "Data de início da assinatura",
        CASE
            WHEN ((s.status)::text = 'canceled'::text) THEN ct.created_at
            ELSE NULL::timestamp without time zone
        END AS "Data do cancelamento da assinatura",
        CASE
            WHEN ((s.status)::text = 'unpaid'::text) THEN last_unpaid_notification.created_at
            ELSE NULL::timestamp without time zone
        END AS "Data da última notificação",
    ((('https://app.bonde.org/subscriptions/'::text || s.id) || '/edit?token='::text) || s.token) AS "Link de alteração da assinatura"
   FROM (((subscriptions s
     JOIN activists a ON ((a.id = s.activist_id)))
     LEFT JOIN LATERAL ( SELECT st.id,
            st.to_state,
            st.metadata,
            st.sort_key,
            st.subscription_id,
            st.most_recent,
            st.created_at,
            st.updated_at
           FROM subscription_transitions st
          WHERE ((st.subscription_id = s.id) AND ((st.to_state)::text = 'canceled'::text))
          ORDER BY st.created_at DESC
         LIMIT 1) ct ON (true))
     LEFT JOIN LATERAL ( SELECT n.id,
            n.activist_id,
            n.notification_template_id,
            n.template_vars,
            n.created_at,
            n.updated_at,
            n.community_id,
            n.user_id,
            n.email,
            n.deliver_at,
            n.delivered_at
           FROM (notifications n
             JOIN notification_templates nt ON ((nt.id = n.notification_template_id)))
          WHERE ((nt.label = 'unpaid_subscription'::text) AND (((n.template_vars ->> 'subscription_id'::text))::integer = s.id))
          ORDER BY n.created_at DESC
         LIMIT 1) last_unpaid_notification ON (true));
}
  end
end
