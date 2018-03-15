begin;

  \i /specs/sql-support/insert_basic_data.sql;

  select plan(3);

  -- insert basic template data
  insert into public.notification_templates(label,community_id,subject_template,body_template,created_at,updated_at)
  values ('test_template',__demo_community_id(), 'test subject', 'test body', now(), now());

  select has_function(
    'public', 'notify', ARRAY['text', 'json']
  );

  select function_returns(
    'public', 'notify', ARRAY['text', 'json'], 'json'
  );

  create or replace function test_notify()
  returns setof text language plpgsql as $$
    declare
      _notification public.notifications;
      _result json;
    begin
      _result := public.notify('test_template', json_build_object(
        'activist_id', __demo_activist_id()
      ));

      select * from public.notifications where id = (_result->>'id')::integer
      into _notification;

      return next is(_notification.id is not null, true, 'should have created notification on database');
    end;
  $$;
  select * from test_notify();

rollback;
