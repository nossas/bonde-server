BEGIN;
    SELECT plan(7);

    -- check table presence
    SELECT has_table('public'::name, 'payable_transfers'::name);

    -- check not nulls
    SELECT col_not_null('public', 'payable_transfers', 'id', 'should be not null');
    SELECT col_not_null('public', 'payable_transfers', 'community_id', 'should be not null');
    SELECT col_not_null('public', 'payable_transfers', 'amount', 'should be not null');
    SELECT col_not_null('public', 'payable_transfers', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'payable_transfers', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'payable_transfers', 'id', 'should be pk');

    -- check foreign keys
    --SELECT fk_ok('public', 'payable_transfers', 'community_id',
    --   'public', 'communities', 'id');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
