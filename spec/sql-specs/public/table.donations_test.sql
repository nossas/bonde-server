BEGIN;
    SELECT plan(16);

    -- check table presence
    SELECT has_table('public'::name, 'donations'::name);

    -- check not nulls
    SELECT col_not_null('public', 'donations', 'id', 'should be not null');
    SELECT col_not_null('public', 'donations', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'donations', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'donations', 'id', 'should be pk');

    SELECT fk_ok('public', 'donations', 'local_subscription_id',
        'public', 'subscriptions', 'id');

    SELECT fk_ok('public', 'donations', 'cached_community_id',
        'public', 'communities', 'id');

    SELECT fk_ok('public', 'donations', 'widget_id',
        'public', 'widgets', 'id');

    SELECT fk_ok('public', 'donations', 'activist_id',
        'public', 'activists', 'id');

    SELECT has_index('public', 'donations', 'index_donations_on_activist_id', 'activist_id', 'index on activist_id column');
    SELECT has_index('public', 'donations', 'index_donations_on_payable_transfer_id', 'payable_transfer_id', 'index on payable_transfer_id column');
    SELECT has_index('public', 'donations', 'index_donations_on_widget_id', 'widget_id', 'index on widget_id column');
    SELECT has_index('public', 'donations', 'index_donations_on_customer', 'customer', 'index on customer column');
    SELECT has_index('public', 'donations', 'index_donations_on_transaction_id', 'transaction_id', 'index on transaction_id column');
    SELECT index_is_unique('public', 'donations', 'index_donations_on_transaction_id');

    SELECT triggers_are('public', 'donations', '{generate_activists_from_generic_resource_with_widget}'::text[]);

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
