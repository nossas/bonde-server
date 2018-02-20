begin;
    -- insert notification template
    insert into public.notification_templates(label, subject_template, body_template, created_at, updated_at)
        values ('reset_password_instructions', 'reset password subject', 'reset password body', now(), now());

    -- insert test user
    insert into public.users(id, email, provider, uid, encrypted_password, admin)
        values (1, 'foo@foo.com', 'bonde', '1', crypt('123456', gen_salt('bf', 9)), false);

  select plan(4);

  select has_function('postgraphql', 'request_reset_password_token', ARRAY['email']);
  select function_returns('postgraphql', 'request_reset_password_token', ARRAY['email'], 'void');

  create or replace function test_request_reset_password_token()
  returns setof text language plpgsql as $$
  declare
    _user public.users;
  begin

    set local role anonymous;
    perform postgraphql.request_reset_password_token('foo@foo.com');
    select * from users where id = 1
    into _user;

    -- should generate a new password reset token
    return next ok((_user.reset_password_token is not null), 'should generate a reset password token');

    set local role postgres;
    -- should sent notification to user
    return next ok(
        (
            select count(1) from public.notifications n
            join notification_templates nt on nt.id = n.notification_template_id
            where n.user_id = _user.id
                and nt.label = 'reset_password_instructions'
        ) > 0,
        'should generate a notification to user'
    );
  end;
  $$;
  select * from test_request_reset_password_token();

rollback;
