BEGIN;
    SELECT plan(9);

    -- check table presence
    SELECT has_table('public'::name, 'recipients'::name);

    -- check not nulls
    SELECT col_not_null('public', 'recipients', 'id', 'should be not null');
    SELECT col_not_null('public', 'recipients', 'pagarme_recipient_id', 'should be not null');
    SELECT col_not_null('public', 'recipients', 'recipient', 'should be not null');
    SELECT col_not_null('public', 'recipients', 'community_id', 'should be not null');
    SELECT col_not_null('public', 'recipients', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'recipients', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'recipients', 'id', 'should be pk');

    -- check foreign keys
    SELECT fk_ok('public', 'recipients', 'community_id',
       'public', 'communities', 'id');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
