BEGIN;
    SELECT plan(13);

    -- check table presence
    SELECT has_table('public'::name, 'activist_facebook_bot_interactions'::name);

    -- check not nulls
    SELECT col_not_null('public', 'activist_facebook_bot_interactions', 'facebook_bot_configuration_id', 'should be not null');
    SELECT col_not_null('public', 'activist_facebook_bot_interactions', 'fb_context_recipient_id', 'should be not null');
    SELECT col_not_null('public', 'activist_facebook_bot_interactions', 'fb_context_sender_id', 'should be not null');
    SELECT col_not_null('public', 'activist_facebook_bot_interactions', 'interaction', 'should be not null');
    SELECT col_not_null('public', 'activist_facebook_bot_interactions', 'updated_at', 'should be not null');
    SELECT col_not_null('public', 'activist_facebook_bot_interactions', 'created_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'activist_facebook_bot_interactions', 'id', 'should be pk');

    SELECT fk_ok('public', 'activist_facebook_bot_interactions', 'activist_id',
        'public', 'activists', 'id');

    SELECT fk_ok('public', 'activist_facebook_bot_interactions', 'facebook_bot_configuration_id',
        'public', 'facebook_bot_configurations', 'id');

    SELECT has_index('public', 'activist_facebook_bot_interactions', 'idx_activists_on_bot_interations', 'activist_id', 'index on activist_id column');
    SELECT has_index('public', 'activist_facebook_bot_interactions', 'idx_bot_config_on_bot_interactions', 'facebook_bot_configuration_id', 'index on facebook_bot_configuration_id');

    SELECT triggers_are('public', 'activist_facebook_bot_interactions', '{update_facebook_bot_activist_data}'::text[]);


    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
