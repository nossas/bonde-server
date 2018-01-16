BEGIN;
    SELECT plan(5);

    -- check table presence
    SELECT has_table('public'::name, 'tags'::name);

    -- check not nulls
    SELECT col_not_null('public', 'tags', 'id', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'tags', 'id', 'should be pk');

    SELECT has_index('public', 'tags', 'index_tags_on_name', 'name', 'index on name column');

    SELECT index_is_unique('public', 'tags', 'index_tags_on_name');

    SELECT * FROM finish();
ROLLBACK;
