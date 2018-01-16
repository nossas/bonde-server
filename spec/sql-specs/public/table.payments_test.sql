BEGIN;
    SELECT plan(4);

    -- check table presence
    SELECT has_table('public'::name, 'payments'::name);

    -- check not nulls
    SELECT col_not_null('public', 'payments', 'id', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'payments', 'id', 'should be pk');

    -- check foreign keys
    -- SELECT fk_ok('public', 'payments', 'donation_id',
    --    'public', 'donations', 'id');

    -- SELECT fk_ok('public', 'payments', 'activist_id',
    --    'public', 'activists', 'id');

    -- SELECT fk_ok('public', 'payments', 'address_id',
    --    'public', 'addresses', 'id');

    -- SELECT fk_ok('public', 'payments', 'credit_card_id',
    --    'public', 'credit_cards', 'id');

    -- check indexes
    SELECT has_index('public', 'payments', 'index_payments_on_donation_id', 'donation_id', 'index on donation_id column');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
