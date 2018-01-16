BEGIN;
    SELECT plan(13);

    -- check table presence
    SELECT has_table('public'::name, 'subscription_transitions'::name);

    -- check not nulls
    SELECT col_not_null('public', 'subscription_transitions', 'id', 'should be not null');
    SELECT col_not_null('public', 'subscription_transitions', 'to_state', 'should be not null');
    SELECT col_not_null('public', 'subscription_transitions', 'sort_key', 'should be not null');
    SELECT col_not_null('public', 'subscription_transitions', 'subscription_id', 'should be not null');
    SELECT col_not_null('public', 'subscription_transitions', 'most_recent', 'should be not null');
    SELECT col_not_null('public', 'subscription_transitions', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'subscription_transitions', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'subscription_transitions', 'id', 'should be pk');

    -- SELECT fk_ok('public', 'subscription_transitions', 'subscription_id',
    --     'public', 'subscriptions', 'id');

    SELECT has_index('public', 'subscription_transitions', 'index_subscription_transitions_parent_most_recent', '{subscription_id, most_recent}'::text[], 'index on subscription_id, most_recent columns');
    SELECT has_index('public', 'subscription_transitions', 'index_subscription_transitions_parent_sort', '{subscription_id, sort_key}'::text[], 'index on subscription_id, sort_key column');


    SELECT index_is_unique('public', 'subscription_transitions', 'index_subscription_transitions_parent_most_recent');
    SELECT index_is_unique('public', 'subscription_transitions', 'index_subscription_transitions_parent_sort');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
