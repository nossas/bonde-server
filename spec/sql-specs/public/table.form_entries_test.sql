BEGIN;
    SELECT plan(9);

    -- check table presence
    SELECT has_table('public'::name, 'form_entries'::name);

    -- check not nulls
    SELECT col_not_null('public', 'form_entries', 'id', 'should be not null');
    SELECT col_not_null('public', 'form_entries', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'form_entries', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'form_entries', 'id', 'should be pk');

    -- check foreign keys
    SELECT fk_ok('public', 'form_entries', 'widget_id',
       'public', 'widgets', 'id');
    SELECT fk_ok('public', 'form_entries', 'cached_community_id',
       'public', 'communities', 'id');
    SELECT fk_ok('public', 'form_entries', 'activist_id',
       'public', 'activists', 'id');

    -- check indexes
    -- SELECT has_index('public', 'form_entries', 'idx_form_entries_activist_id', 'activist_id', 'index on column');
    SELECT has_index('public', 'form_entries', 'index_form_entries_on_widget_id', 'widget_id', 'index on column');


    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
