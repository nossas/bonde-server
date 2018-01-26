BEGIN;
    SELECT plan(6);

    -- check table presence
    SELECT has_table('public'::name, 'blocks'::name);

    -- check not nulls
    SELECT col_not_null('public', 'blocks', 'id', 'should be not null');
    SELECT col_not_null('public', 'blocks', 'updated_at', 'should be not null');
    SELECT col_not_null('public', 'blocks', 'created_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'blocks', 'id', 'should be pk');

    -- SELECT fk_ok('public', 'blocks', 'mobilization_id',
    --    'public', 'mobilizations', 'id');

    SELECT has_index('public', 'blocks', 'ids_blocks_mob_id', 'mobilization_id', 'index on mobilization_id column');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
