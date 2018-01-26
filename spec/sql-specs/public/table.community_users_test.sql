BEGIN;
    SELECT plan(5);

    -- check table presence
    SELECT has_table('public'::name, 'community_users'::name);

    -- check not nulls
    SELECT col_not_null('public', 'community_users', 'id', 'should be not null');
    SELECT col_not_null('public', 'community_users', 'updated_at', 'should be not null');
    SELECT col_not_null('public', 'community_users', 'created_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'community_users', 'id', 'should be pk');

    --SELECT fk_ok('public', 'community_users', 'user_id',
    --    'public', 'users', 'id');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
