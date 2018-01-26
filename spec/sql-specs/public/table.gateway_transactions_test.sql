BEGIN;
    SELECT plan(5);

    -- check table presence
    SELECT has_table('public'::name, 'gateway_transactions'::name);

    -- check not nulls
    SELECT col_not_null('public', 'gateway_transactions', 'id', 'should be not null');
    SELECT col_not_null('public', 'gateway_transactions', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'gateway_transactions', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'gateway_transactions', 'id', 'should be pk');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
