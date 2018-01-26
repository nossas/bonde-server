BEGIN;
    SELECT plan(11);

    -- check table presence
    SELECT has_table('public'::name, 'mobilizations'::name);

    -- check not nulls
    SELECT col_not_null('public', 'mobilizations', 'id', 'should be not null');
    SELECT col_not_null('public', 'mobilizations', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'mobilizations', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'mobilizations', 'id', 'should be pk');

    -- check foreign keys
    SELECT fk_ok('public', 'mobilizations', 'community_id',
       'public', 'communities', 'id');

    -- check indexes
    SELECT has_index('public', 'mobilizations', 'idx_mobilizations_custom_domain', 'custom_domain', 'index on custom_domain column');
    SELECT has_index('public', 'mobilizations', 'idx_mobilizations_slug', 'slug', 'index on slug column');
    SELECT has_index('public', 'mobilizations', 'index_mobilizations_on_community_id', 'community_id', 'index on community_id column');
    SELECT has_index('public', 'mobilizations', 'index_mobilizations_on_custom_domain', 'custom_domain', 'index on custom_domain column');
    SELECT index_is_unique('public', 'mobilizations', 'index_mobilizations_on_custom_domain');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
