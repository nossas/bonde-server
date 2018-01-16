BEGIN;
    SELECT plan(11);

    -- check table presence
    SELECT has_table('public'::name, 'facebook_bot_configurations'::name);

    -- check not nulls
    SELECT col_not_null('public', 'facebook_bot_configurations', 'id', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_configurations', 'messenger_app_secret', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_configurations', 'messenger_validation_token', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_configurations', 'messenger_page_access_token', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_configurations', 'data', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_configurations', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_configurations', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'facebook_bot_configurations', 'id', 'should be pk');

    -- check foreign keys
    -- SELECT fk_ok('public', 'facebook_bot_configurations', 'community_id',
    --    'public', 'communities', 'id');

    -- check indexes
    SELECT has_index('public', 'facebook_bot_configurations', 'uniq_m_page_access_token_idx', 'messenger_page_access_token', 'index on messenger_page_access_token column');
    SELECT index_is_unique('public', 'facebook_bot_configurations', 'uniq_m_page_access_token_idx');


    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
