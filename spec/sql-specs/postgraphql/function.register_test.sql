begin;
  \i ./spec/sql-support/insert_basic_data.sql;

  select plan(13);

  select has_function('postgraphql', 'register', ARRAY['json']);
  select function_returns('postgraphql', 'register', ARRAY['json'], 'postgraphql.jwt_token');

  insert into public.notification_templates(label,subject_template,body_template,created_at,updated_at)
  values ('welcome_user','test subject', 'test body', now(), now());

  create or replace function test_register_with_common_user()
  returns setof text language plpgsql as $$
  declare
  begin

    set local role common_user;
    return next throws_matching(
      'select postgraphql.register(''{"first_name": "lorem", "email": "lorem@lorem.com", "password": "123456"}''::json)',
      'user_already_logged',
      'should be raise does not have permission'
    );
  end;
  $$;
  select * from test_register_with_common_user();

  create or replace function test_register_with_admin()
  returns setof text language plpgsql as $$
  declare
  begin
    set local role admin;
    return next throws_matching(
      'select postgraphql.register(''{"first_name": "lorem", "email": "lorem@lorem.com", "password": "123456"}''::json)',
      'user_already_logged',
      'should be raise does not have permission'
    );
  end;
  $$;
  select * from test_register_with_admin();

  create or replace function test_register()
  returns setof text language plpgsql as $$
  declare
    _user public.users;
    _token postgraphql.jwt_token;
  begin

    set local role anonymous;

    -- test missing requied attributes
    return next throws_matching(
      'select postgraphql.register(''{"first_name": "", "email": "email@email.com", "password": "123456"}''::json)',
      'missing_first_name',
      'should be raise when missing first_name'
    );
    return next throws_matching(
      'select postgraphql.register(''{"first_name": "lorem", "email": "", "password": "123456"}''::json)',
      'missing_email',
      'should be raise when missing email'
    );
    return next throws_matching(
      'select postgraphql.register(''{"first_name": "lorem", "email": "lorem@lorem.com", "password": ""}''::json)',
      'missing_password',
      'should be raise when missing password'
    );
    return next throws_matching(
      'select postgraphql.register(''{"first_name": "lorem", "email": "lorem@lorem.com", "password": "1234"}''::json)',
      'password_lt_six_chars',
      'should be raise when password < 6'
    );
    return next throws_matching(
      'select postgraphql.register(''{"first_name": "lorem", "email": "lorem-lorem.com", "password": "123456"}''::json)',
      'email_check',
      'should be raise when email is not valid email'
    );

     -- should register and generate the user
     _token := postgraphql.register(
       json_build_object(
         'first_name', 'Lorem Name',
         'email', 'lorem@email.com',
         'password', 'lorempassword')
     );
     return next is(_token.role, 'common_user', 'should jwt with role common_user');
     return next is(_token.user_id is not null, true, 'should jwt with user_id filled');

    -- should generate welcome notification
    return next is((
      select true from notifications n
        join notification_templates nt on nt.id = n.notification_template_id
        where n.user_id = _token.user_id
        and nt.label = 'welcome_user'
    ), true, 'should have generate welcome_user notification after registration');

    -- should aise error when email already take
    return next throws_matching(
      'select postgraphql.register(''{"first_name": "lorem", "email": "lorem@email.com", "password": "123456"}''::json)',
      '.unique',
      'should be unique email'
    );
  end;
  $$;

  select * from test_register();
rollback;
