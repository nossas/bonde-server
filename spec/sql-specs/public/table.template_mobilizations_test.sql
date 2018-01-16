BEGIN;
    SELECT plan(6);

    -- check table presence
    SELECT has_table('public'::name, 'template_mobilizations'::name);

    -- check not nulls
    SELECT col_not_null('public', 'template_mobilizations', 'id', 'should be not null');
    SELECT col_not_null('public', 'template_mobilizations', 'slug', 'should be not null');
    SELECT col_not_null('public', 'template_mobilizations', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'template_mobilizations', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'template_mobilizations', 'id', 'should be pk');

    -- SELECT fk_ok('public', 'template_mobilizations', 'community_id',
    --     'public', 'communities', 'id');

    SELECT * FROM finish();
ROLLBACK;
