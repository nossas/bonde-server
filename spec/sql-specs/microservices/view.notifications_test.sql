begin;

  \i /specs/sql-support/insert_basic_data.sql;

  select plan(5);

  select has_view('microservices'::name, 'notifications'::name, 'should have view defined');

  -- insert basic template data
  insert into public.notification_templates(id,label,community_id,subject_template,body_template,created_at,updated_at)
  values (9999, 'test_template',__demo_community_id(), 'test subject', 'test body', now(), now());

  -- insert basic notification
  insert into public.notifications(activist_id, notification_template_id, template_vars, created_at, updated_at)
  values (__demo_activist_id(), 9999, '{"amount": 10}'::jsonb, now(), now());

  prepare get_notifications as select * from microservices.notifications limit 1;


  create or replace function test_with_microservices_role()
  returns setof text language plpgsql as $$
    declare
      _notification microservices.notifications;
    begin
      set local role microservices;
      select * from microservices.notifications
      where notification_template_id = 9999 limit 1
      into _notification;

      return next is(_notification.id is not null, true, 'microservices role can get notification');
      set local role postgres;
    end;
  $$;
  select * from test_with_microservices_role();


  create or replace function test_with_non_microservices_role()
  returns setof text language plpgsql as $$
    declare
    begin
      set local role anonymous;
      return next throws_matching('get_notifications', 'permission denied', 'should not permit non microservices role');

      set local role common_user;
      return next throws_matching('get_notifications', 'permission denied', 'should not permit non microservices role');

      set local role admin;
      return next throws_matching('get_notifications', 'permission denied', 'should not permit non microservices role');
    end;
  $$;
  select * from test_with_non_microservices_role();

rollback;
