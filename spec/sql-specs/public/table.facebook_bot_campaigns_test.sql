BEGIN;
    SELECT plan(11);

    -- check table presence
    SELECT has_table('public'::name, 'facebook_bot_campaigns'::name);

    -- check not nulls
    SELECT col_not_null('public', 'facebook_bot_campaigns', 'id', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_campaigns', 'facebook_bot_configuration_id', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_campaigns', 'name', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_campaigns', 'segment_filters', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_campaigns', 'total_impacted_activists', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_campaigns', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_campaigns', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'facebook_bot_campaigns', 'id', 'should be pk');

    -- check foreign keys
    SELECT fk_ok('public', 'facebook_bot_campaigns', 'facebook_bot_configuration_id',
       'public', 'facebook_bot_configurations', 'id');

    -- check indexes
    SELECT has_index('public', 'facebook_bot_campaigns', 'index_facebook_bot_campaigns_on_facebook_bot_configuration_id', 'facebook_bot_configuration_id', 'index on facebook_bot_configuration_id column');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
