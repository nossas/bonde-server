BEGIN;
    SELECT plan(5);

    -- check table presence
    SELECT has_table('public'::name, 'credit_cards'::name);

    -- check not nulls
    SELECT col_not_null('public', 'credit_cards', 'id', 'should be not null');
    SELECT col_not_null('public', 'credit_cards', 'card_id', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'credit_cards', 'id', 'should be pk');

    -- SELECT fk_ok('public', 'credit_cards', 'activist_id',
    --     'public', 'activists', 'id');

    SELECT has_index('public', 'credit_cards', 'index_credit_cards_on_activist_id', 'activist_id', 'index on activist_id columns');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
