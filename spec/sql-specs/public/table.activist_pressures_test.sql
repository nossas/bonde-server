BEGIN;
    SELECT plan(10);

    -- check table presence
    SELECT has_table('public'::name, 'activist_pressures'::name);

    -- check not nulls
    SELECT col_not_null('public', 'activist_pressures', 'updated_at', 'should be not null');
    SELECT col_not_null('public', 'activist_pressures', 'created_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'activist_pressures', 'id', 'should be pk');

    SELECT fk_ok('public', 'activist_pressures', 'activist_id',
        'public', 'activists', 'id');

    SELECT fk_ok('public', 'activist_pressures', 'widget_id',
        'public', 'widgets', 'id');

    SELECT fk_ok('public', 'activist_pressures', 'cached_community_id',
        'public', 'communities', 'id');

    SELECT has_index('public', 'activist_pressures', 'index_activist_pressures_on_activist_id', 'activist_id', 'index on activist_id column');
    SELECT has_index('public', 'activist_pressures', 'index_activist_pressures_on_widget_id', 'widget_id', 'index on widget_id');

    SELECT triggers_are('public', 'activist_pressures', '{generate_activists_from_generic_resource_with_widget}'::text[]);


    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
