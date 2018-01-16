BEGIN;
    SELECT plan(7);

    -- check table presence
    SELECT has_table('public'::name, 'gateway_subscriptions'::name);

    -- check not nulls
    SELECT col_not_null('public', 'gateway_subscriptions', 'id', 'should be not null');
    SELECT col_not_null('public', 'gateway_subscriptions', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'gateway_subscriptions', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'gateway_subscriptions', 'id', 'should be pk');

    -- check indexes
    SELECT has_index('public', 'gateway_subscriptions', 'index_gateway_subscriptions_on_subscription_id', 'subscription_id', 'index on subscription_id column');
    SELECT index_is_unique('public', 'gateway_subscriptions', 'index_gateway_subscriptions_on_subscription_id');


    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
