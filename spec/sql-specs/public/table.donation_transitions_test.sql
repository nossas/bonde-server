BEGIN;
    SELECT plan(13);

    -- check table presence
    SELECT has_table('public'::name, 'donation_transitions'::name);

    -- check not nulls
    SELECT col_not_null('public', 'donation_transitions', 'id', 'should be not null');
    SELECT col_not_null('public', 'donation_transitions', 'to_state', 'should be not null');
    SELECT col_not_null('public', 'donation_transitions', 'sort_key', 'should be not null');
    SELECT col_not_null('public', 'donation_transitions', 'donation_id', 'should be not null');
    SELECT col_not_null('public', 'donation_transitions', 'most_recent', 'should be not null');
    SELECT col_not_null('public', 'donation_transitions', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'donation_transitions', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'donation_transitions', 'id', 'should be pk');

    -- SELECT fk_ok('public', 'donation_transitions', 'donation_id',
    --     'public', 'donations', 'id');

    SELECT has_index('public', 'donation_transitions', 'index_donation_transitions_parent_most_recent', '{donation_id, most_recent}'::text[], 'index on donation_id, most_recent columns');
    SELECT has_index('public', 'donation_transitions', 'index_donation_transitions_parent_sort', '{donation_id, sort_key}'::text[], 'index on donation_id, sort_key column');


    SELECT index_is_unique('public', 'donation_transitions', 'index_donation_transitions_parent_most_recent');
    SELECT index_is_unique('public', 'donation_transitions', 'index_donation_transitions_parent_sort');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
