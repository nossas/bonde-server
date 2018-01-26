BEGIN;
    SELECT plan(5);

    -- check table presence
    SELECT has_table('public'::name, 'template_widgets'::name);

    -- check not nulls
    SELECT col_not_null('public', 'template_widgets', 'id', 'should be not null');
    SELECT col_not_null('public', 'template_widgets', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'template_widgets', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'template_widgets', 'id', 'should be pk');

    -- SELECT fk_ok('public', 'template_widgets', 'widget_id',
    --     'public', 'widgets', 'id');

    SELECT * FROM finish();
ROLLBACK;
