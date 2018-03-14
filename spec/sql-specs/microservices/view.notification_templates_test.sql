begin;

  \i /specs/sql-support/insert_basic_data.sql;

  select plan(5);

  select has_view('microservices'::name, 'notification_templates'::name, 'should have view defined');

  -- insert basic template data
  insert into public.notification_templates(label,community_id,subject_template,body_template,created_at,updated_at)
  values ('test_template',__demo_community_id(), 'test subject', 'test body', now(), now());

  prepare get_templates as select * from microservices.notification_templates where label = 'test_template' limit 1;

  create or replace function test_with_microservices_role()
  returns setof text language plpgsql as $$
    declare
      _template microservices.notification_templates;
    begin
      set local role microservices;
      select * from microservices.notification_templates
      where label = 'test_template' limit 1
      into _template;

      return next is(_template.label, 'test_template');
      set local role postgres;
    end;
  $$;
  select * from test_with_microservices_role();

  create or replace function test_with_non_microservices_role()
  returns setof text language plpgsql as $$
    declare
    begin
      set local role anonymous;
      return next throws_matching('get_templates', 'permission denied', 'should not permit non microservices role');

      set local role common_user;
      return next throws_matching('get_templates', 'permission denied', 'should not permit non microservices role');

      set local role admin;
      return next throws_matching('get_templates', 'permission denied', 'should not permit non microservices role');
    end;
  $$;
  select * from test_with_non_microservices_role();

rollback;
