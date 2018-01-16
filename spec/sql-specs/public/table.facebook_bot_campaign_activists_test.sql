BEGIN;
    SELECT plan(12);

    -- check table presence
    SELECT has_table('public'::name, 'facebook_bot_campaign_activists'::name);

    -- check not nulls
    SELECT col_not_null('public', 'facebook_bot_campaign_activists', 'id', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_campaign_activists', 'facebook_bot_campaign_id', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_campaign_activists', 'facebook_bot_activist_id', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_campaign_activists', 'received', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_campaign_activists', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_campaign_activists', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'facebook_bot_campaign_activists', 'id', 'should be pk');

    -- check foreign keys
    SELECT fk_ok('public', 'facebook_bot_campaign_activists', 'facebook_bot_campaign_id',
       'public', 'facebook_bot_campaigns', 'id');

    SELECT fk_ok('public', 'facebook_bot_campaign_activists', 'facebook_bot_activist_id',
       'public', 'facebook_bot_activists', 'id');

    -- check indexes
    SELECT has_index('public', 'facebook_bot_campaign_activists', 'idx_facebook_bot_campaign_activists_on_facebook_bot_activist_id', 'facebook_bot_activist_id', 'index on facebook_bot_activist_id column');
    SELECT has_index('public', 'facebook_bot_campaign_activists', 'idx_facebook_bot_campaign_activists_on_facebook_bot_campaign_id', 'facebook_bot_campaign_id', 'index on facebook_bot_campaign_id column');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
