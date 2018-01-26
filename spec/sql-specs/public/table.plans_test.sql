BEGIN;
    SELECT plan(3);

    -- check table presence
    SELECT has_table('public'::name, 'plans'::name);

    -- check not nulls
    SELECT col_not_null('public', 'plans', 'id', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'plans', 'id', 'should be pk');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
