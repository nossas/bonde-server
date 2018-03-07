BEGIN;
    -- insert test user
    insert into public.users(id, email, provider, uid, encrypted_password, admin)
        values (1, 'foo@foo.com', 'bonde', '1', crypt('123456', gen_salt('bf', 9)), false);

    select plan(8);

    select has_function(
        'postgraphql', 'authenticate', ARRAY['text', 'text']
    );

    select function_returns(
        'postgraphql', 'authenticate', ARRAY['text', 'text'], 'postgraphql.jwt_token'
    );


    create or replace function test_authenticate()
    returns setof text language plpgsql as $$
    declare
        _user public.users;
        _token postgraphql.jwt_token;
    begin
        select * from public.users where id = 1
        into _user;

        set local role anonymous;

        -- try auth with invalid password
        _token := postgraphql.authenticate('foo@foo.com', '123');
        return next is(_token, null, 'should not get a token');

        -- try auth with valid pass
        _token := postgraphql.authenticate('foo@foo.com', '123456');
        return next is(_token is null, false, 'should get a token');
        return next is(_token.role, 'common_user', 'should role be setted has common_user');
        return next is(_token.user_id, _user.id, 'should user_id be setted with authenticated user_id');
        set local role postgres;
    end;
    $$;
    select * from test_authenticate();

    create or replace function test_authenticate_with_admin()
    returns setof text language plpgsql as $$
    declare
        _user public.users;
        _token postgraphql.jwt_token;
    begin
        select * from public.users where id = 1
        into _user;
        -- update to admin true
        update users set admin = true where id = 1;

        set local role anonymous;

        _token := postgraphql.authenticate('foo@foo.com', '123456');
        return next is(_token.role, 'admin', 'should role be setted has admin');
        return next is(_token.user_id, _user.id, 'should user_id be setted with authenticated user_id');
    end;
    $$;
    select * from test_authenticate_with_admin();
ROLLBACK;

