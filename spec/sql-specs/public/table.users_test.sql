BEGIN;
    SELECT plan(12);

    -- check table presence
    SELECT has_table('public'::name, 'users'::name);

    -- check not nulls
    SELECT col_not_null('public', 'users', 'id', 'should be not null');
    SELECT col_not_null('public', 'users', 'provider', 'should be not null');
    SELECT col_not_null('public', 'users', 'uid', 'should be not null');
    SELECT col_not_null('public', 'users', 'encrypted_password', 'should be not null');
    SELECT col_not_null('public', 'users', 'sign_in_count', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'users', 'id', 'should be pk');

    -- SELECT fk_ok('public', 'widgets', 'block_id', 'public', 'blocks', 'id');

    SELECT has_index('public', 'users', 'index_users_on_email', 'email', 'index on columns');
    SELECT has_index('public', 'users', 'index_users_on_reset_password_token', 'reset_password_token', 'index on columns');
    SELECT has_index('public', 'users', 'index_users_on_uid_and_provider', '{uid, provider}'::text[], 'index on columns');

    SELECT index_is_unique('public', 'users', 'index_users_on_reset_password_token');
    SELECT index_is_unique('public', 'users', 'index_users_on_uid_and_provider');

    SELECT * FROM finish();
ROLLBACK;
