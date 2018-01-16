BEGIN;
    SELECT plan(6);

    -- check table presence
    SELECT has_table('public'::name, 'addresses'::name);

    -- check not nulls
    SELECT col_not_null('public', 'addresses', 'updated_at', 'should be not null');
    SELECT col_not_null('public', 'addresses', 'created_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'addresses', 'id', 'should be pk');

    SELECT fk_ok('public', 'addresses', 'activist_id',
        'public', 'activists', 'id');

    SELECT has_index('public', 'addresses', 'index_addresses_on_activist_id', 'activist_id', 'index on activist_id column');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
