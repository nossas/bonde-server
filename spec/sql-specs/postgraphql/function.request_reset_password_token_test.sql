begin;
    -- insert notification template
    insert into public.notification_templates(label, subject_template, body_template, created_at, updated_at, locale)
        values ('reset_password_instructions', 'reset password subject', 'reset password body', now(), now(), 'pt-BR'),
        ('reset_password_instructions', 'reset password subject', 'reset password body', now(), now(), 'es');

    -- insert test user
    insert into public.users(id, email, provider, uid, encrypted_password, admin, locale) values 
        (1, 'foo@foo.com', 'bonde', '1', crypt('123456', gen_salt('bf', 9)), false, 'pt-BR'),
        (2, 'foo2@foo.com', 'bonde', '2', crypt('123456', gen_salt('bf', 9)), false, 'es'),
        (3, 'foo3@foo.com', 'bonde', '3', crypt('123456', gen_salt('bf', 9)), false, 'en');

  select plan(8);

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

    -- should sent notification to user in they locale
    return next ok(
        (
            select count(1) from public.notifications n
            join notification_templates nt on nt.id = n.notification_template_id
            where n.user_id = _user.id
                and nt.label = 'reset_password_instructions'
                and nt.locale = _user.locale
        ) > 0,
        'should generate a notification to user in they default location'
    );


    perform postgraphql.request_reset_password_token('foo2@foo.com');
    select * from users where id = 2
    into _user;

    -- should generate a new password reset token
    return next ok((_user.reset_password_token is not null), 'should generate a reset password token');

    -- should sent notification to user in they locale
    return next ok(
        (
            select count(1) from public.notifications n
            join notification_templates nt on nt.id = n.notification_template_id
            where n.user_id = _user.id
                and nt.label = 'reset_password_instructions'
                and nt.locale = _user.locale
        ) > 0,
        'should generate a notification to user in they default location'
    );


    perform postgraphql.request_reset_password_token('foo3@foo.com');
    select * from users where id = 3
    into _user;

    -- should generate a new password reset token
    return next ok((_user.reset_password_token is not null), 'should generate a reset password token');

    -- should sent notification to user in they locale
    return next ok(
        (
            select count(1) from public.notifications n
            join notification_templates nt on nt.id = n.notification_template_id
            where n.user_id = _user.id
                and nt.label = 'reset_password_instructions'
                and nt.locale = 'pt-BR'
        ) > 0,
        'should generate a notification to user in default location when they location not exists'
    );


    set local role postgres; -- rollback to default role

  end;
  $$;
  select * from test_request_reset_password_token();

rollback;
