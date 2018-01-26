BEGIN;
    SELECT plan(7);

    -- check table presence
    SELECT has_table('public'::name, 'matches'::name);

    -- check not nulls
    SELECT col_not_null('public', 'matches', 'id', 'should be not null');
    SELECT col_not_null('public', 'matches', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'matches', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'matches', 'id', 'should be pk');

    -- check foreign keys
    SELECT fk_ok('public', 'matches', 'widget_id',
       'public', 'widgets', 'id');

    -- check indexes
    SELECT has_index('public', 'matches', 'index_matches_on_widget_id', 'widget_id', 'index on widget_id column');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
