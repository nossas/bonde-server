BEGIN;
    SELECT plan(5);

    -- check table presence
    SELECT has_table('public'::name, 'template_blocks'::name);

    -- check not nulls
    SELECT col_not_null('public', 'template_blocks', 'id', 'should be not null');
    SELECT col_not_null('public', 'template_blocks', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'template_blocks', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'template_blocks', 'id', 'should be pk');

    -- SELECT fk_ok('public', 'template_blocks', 'template_mobilization_id',
    --     'public', 'template_mobilizations', 'id');

    SELECT * FROM finish();
ROLLBACK;
