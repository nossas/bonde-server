BEGIN;
    SELECT plan(7);

    -- check table presence
    SELECT has_table('public'::name, 'invitations'::name);

    -- check not nulls
    SELECT col_not_null('public', 'invitations', 'id', 'should be not null');
    SELECT col_not_null('public', 'invitations', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'invitations', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'invitations', 'id', 'should be pk');

    -- check foreign keys
    SELECT fk_ok('public', 'invitations', 'community_id',
       'public', 'communities', 'id');
    -- SELECT fk_ok('public', 'invitations', 'user_id',
    --    'public', 'users', 'id');

    -- check indexes
    SELECT has_index('public', 'invitations', 'index_invitations_on_community_id_and_code', '{community_id, code}'::text[], 'index on community_id, code column');


    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
