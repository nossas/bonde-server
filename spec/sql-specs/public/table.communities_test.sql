BEGIN;
    SELECT plan(4);

    -- check table presence
    SELECT has_table('public'::name, 'communities'::name);

    -- check not nulls
    SELECT col_not_null('public', 'communities', 'created_at', 'created_at should be not null');
    SELECT col_not_null('public', 'communities', 'updated_at', 'updated_at should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'communities', 'id', 'name should be pk');


    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
