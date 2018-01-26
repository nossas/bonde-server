BEGIN;
    SELECT plan(10);

    -- check table presence
    SELECT has_table('public'::name, 'balance_operations'::name);

    -- check not nulls
    SELECT col_not_null('public', 'balance_operations', 'id', 'should be not null');
    SELECT col_not_null('public', 'balance_operations', 'recipient_id', 'should be not null');
    SELECT col_not_null('public', 'balance_operations', 'gateway_data', 'should be not null');
    SELECT col_not_null('public', 'balance_operations', 'gateway_id', 'should be not null');
    SELECT col_not_null('public', 'balance_operations', 'updated_at', 'should be not null');
    SELECT col_not_null('public', 'balance_operations', 'created_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'balance_operations', 'id', 'should be pk');

    SELECT fk_ok('public', 'balance_operations', 'recipient_id',
        'public', 'recipients', 'id');

    SELECT has_index('public', 'balance_operations', 'index_balance_operations_on_recipient_id', 'recipient_id', 'index on recipient_id column');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
