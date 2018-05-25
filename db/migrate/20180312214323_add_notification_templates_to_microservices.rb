class AddNotificationTemplatesToMicroservices < ActiveRecord::Migration
  def up
    execute %Q{
create or replace view microservices.notification_templates as
    select
        *
    from public.notification_templates
    order by created_at desc;

create or replace view microservices.notifications as
    select
        *
    from public.notifications
    order by created_at desc;


grant usage on schema microservices to microservices;
grant select on notification_templates to microservices;
grant select on notifications to microservices;
grant select on microservices.notification_templates to microservices;
grant select on microservices.notifications to microservices;
}
  end

  def down
    execute %Q{
drop view microservices.notification_templates;
drop view microservices.notifications;
}
  end
end
