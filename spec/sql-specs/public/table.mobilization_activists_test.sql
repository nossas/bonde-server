BEGIN;
    SELECT plan(13);

    -- check table presence
    SELECT has_table('public'::name, 'mobilization_activists'::name);

    -- check not nulls
    SELECT col_not_null('public', 'mobilization_activists', 'id', 'should be not null');
    SELECT col_not_null('public', 'mobilization_activists', 'mobilization_id', 'should be not null');
    SELECT col_not_null('public', 'mobilization_activists', 'activist_id', 'should be not null');
    SELECT col_not_null('public', 'mobilization_activists', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'mobilization_activists', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'mobilization_activists', 'id', 'should be pk');

    -- check foreign keys
    SELECT fk_ok('public', 'mobilization_activists', 'mobilization_id',
       'public', 'mobilizations', 'id');
    SELECT fk_ok('public', 'mobilization_activists', 'activist_id',
       'public', 'activists', 'id');

    -- check indexes
    SELECT has_index('public', 'mobilization_activists', 'index_mobilization_activists_on_activist_id', 'activist_id', 'index on activist_id column');
    SELECT has_index('public', 'mobilization_activists', 'index_mobilization_activists_on_mobilization_id', 'mobilization_id', 'index on mobilization_id column');
    SELECT has_index('public', 'mobilization_activists', 'index_mobilization_activists_on_mobilization_id_and_activist_id', '{mobilization_id, activist_id}'::text[], 'index on mobilization_id, activist_id column');
    SELECT index_is_unique('public', 'mobilization_activists', 'index_mobilization_activists_on_mobilization_id_and_activist_id');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
