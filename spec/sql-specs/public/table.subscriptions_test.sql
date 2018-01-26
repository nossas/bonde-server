BEGIN;
    SELECT plan(10);

    -- check table presence
    SELECT has_table('public'::name, 'subscriptions'::name);

    -- check not nulls
    SELECT col_not_null('public', 'subscriptions', 'id', 'should be not null');
    SELECT col_not_null('public', 'subscriptions', 'payment_method', 'should be not null');
    SELECT col_not_null('public', 'subscriptions', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'subscriptions', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'subscriptions', 'id', 'should be pk');

    SELECT fk_ok('public', 'subscriptions', 'activist_id',
        'public', 'activists', 'id');

    SELECT fk_ok('public', 'subscriptions', 'community_id',
        'public', 'communities', 'id');

    SELECT fk_ok('public', 'subscriptions', 'widget_id',
        'public', 'widgets', 'id');

    SELECT triggers_are('public', 'subscriptions', '{generate_activists_from_generic_resource_with_widget}'::text[]);

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
