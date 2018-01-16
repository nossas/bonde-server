BEGIN;
    SELECT plan(10);

    -- check table presence
    SELECT has_table('public'::name, 'activists'::name);

    -- check not nulls
    SELECT col_not_null('public', 'activists', 'name', 'should be not null');
    SELECT col_not_null('public', 'activists', 'email', 'should be not null');
    SELECT col_not_null('public', 'activists', 'updated_at', 'should be not null');
    SELECT col_not_null('public', 'activists', 'created_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'activists', 'id', 'should be pk');

    SELECT has_index('public', 'activists', 'index_activists_on_created_at', 'created_at', 'index on created_at column');
    SELECT has_index('public', 'activists', 'index_activists_on_email', 'email', 'index on email');
    SELECT has_index('public', 'activists', 'uniq_email_acts', 'lower(((email)::email)::text)', 'index on email');

    SELECT index_is_unique('public', 'activists', 'uniq_email_acts', 'email should be unique');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
