begin;
    -- insert test user
    insert into public.users(id, email, provider, uid, encrypted_password, admin, reset_password_token)
        values (1, 'foo@foo.com', 'bonde', '1', crypt('123456', gen_salt('bf', 9)), false, 'reset_token_test');

  select plan(12);

  select has_function('postgraphql', 'change_password', ARRAY['json']);
  select function_returns('postgraphql', 'change_password', ARRAY['json'], 'postgraphql.jwt_token');


  create or replace function test_change_with_authenticated_user()
  returns setof text language plpgsql as $$
  declare
    _user public.users;
    _changed_password_user public.users;
    _token postgraphql.jwt_token;
  begin
    select * from users where id = 1
    into _user;

    set local role common_user;
    set local jwt.claims.user_id to 1;

    -- test success change
    _token := postgraphql.change_password(json_build_object(
        'password', '1234567',
        'password_confirmation', '1234567'
    ));
    select * from users where id = _token.user_id
        into _changed_password_user;

    return next is(_user.encrypted_password <> _changed_password_user.encrypted_password, true, 'should change passwod hash');

    -- test with missing password
    return next throws_matching(
        'select * from postgraphql.change_password(''{"reset_password_token": "reset_token_test"}''::json);',
        'missing_password',
        'should raise error when missing password'
    );

    -- test with small password
    return next throws_matching(
        'select * from postgraphql.change_password(''{"reset_password_token": "reset_token_test", "password": "1234"}''::json);',
        'password_lt_six_chars',
        'should raise error when missing password size'
    );

    -- test with password not equal password_confirmation
    return next throws_matching(
        'select * from postgraphql.change_password(''{"reset_password_token": "reset_token_test", "password": "1234567", "password_confirmation": "12345678"}''::json);',
        'password_confirmation_not_match',
        'should raise error when password confirmation dont match'
    );
  end;
  $$;
  select * from test_change_with_authenticated_user();

  create or replace function test_change_with_reset_token()
  returns setof text language plpgsql as $$
  declare
    _user public.users;
    _changed_password_user public.users;
    _token postgraphql.jwt_token;
  begin
    select * from users where id = 1
    into _user;

    set local role anonymous;

    -- test success change
    _token := postgraphql.change_password(json_build_object(
        'reset_password_token', 'reset_token_test',
        'password', '1234567',
        'password_confirmation', '1234567'
    ));
    select * from users where id = _token.user_id
        into _changed_password_user;

    return next is(_user.encrypted_password <> _changed_password_user.encrypted_password, true, 'should change passwod hash');

    -- test with missing token
    return next throws_matching(
        'select * from postgraphql.change_password(''{"reset_password_token": "", "password": "1234567", "password_confirmation": "1234567"}''::json);',
        'missing_reset_password_token',
        'should raise error when missing reset password token'
    );

    -- test with missing password
    return next throws_matching(
        'select * from postgraphql.change_password(''{"reset_password_token": "reset_token_test"}''::json);',
        'missing_password',
        'should raise error when missing password'
    );

    -- test with small password
    return next throws_matching(
        'select * from postgraphql.change_password(''{"reset_password_token": "reset_token_test", "password": "1234"}''::json);',
        'password_lt_six_chars',
        'should raise error when missing password size'
    );

    -- test with password not equal password_confirmation
    return next throws_matching(
        'select * from postgraphql.change_password(''{"reset_password_token": "reset_token_test", "password": "1234567", "password_confirmation": "12345678"}''::json);',
        'password_confirmation_not_match',
        'should raise error when password confirmation dont match'
    );

    -- test with password not equal password_confirmation
    return next throws_matching(
        'select * from postgraphql.change_password(''{"reset_password_token": "reset_token_", "password": "1234567", "password_confirmation": "1234567"}''::json);',
        'invalid_reset_password_token',
        'should raise error when not found reset_password_token'
    );
  end;
  $$;
  select * from test_change_with_reset_token();

rollback;
