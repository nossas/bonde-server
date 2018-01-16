BEGIN;
    SELECT plan(8);

    -- check table presence
    SELECT has_table('public'::name, 'widgets'::name);

    -- check not nulls
    SELECT col_not_null('public', 'widgets', 'id', 'should be not null');
    SELECT col_not_null('public', 'widgets', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'widgets', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'widgets', 'id', 'should be pk');

    -- SELECT fk_ok('public', 'widgets', 'block_id', 'public', 'blocks', 'id');

    SELECT has_index('public', 'widgets', 'ids_widgets_block_id', 'block_id', 'index on columns');
    SELECT has_index('public', 'widgets', 'ids_widgets_kind', 'kind', 'index on columns');
    SELECT has_index('public', 'widgets', 'ordasc_widgets', 'id', 'index on columns');

    SELECT * FROM finish();
ROLLBACK;
