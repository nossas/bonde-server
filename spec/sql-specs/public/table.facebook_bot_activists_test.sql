BEGIN;
    SELECT plan(13);

    -- check table presence
    SELECT has_table('public'::name, 'facebook_bot_activists'::name);

    -- check not nulls
    SELECT col_not_null('public', 'facebook_bot_activists', 'id', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_activists', 'fb_context_recipient_id', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_activists', 'fb_context_sender_id', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_activists', 'data', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_activists', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'facebook_bot_activists', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'facebook_bot_activists', 'id', 'should be pk');

    -- check indexes
    SELECT has_index('public', 'facebook_bot_activists', 'index_facebook_bot_activists_on_interaction_dates', 'interaction_dates', 'index on interaction_dates column');
    SELECT has_index('public', 'facebook_bot_activists', 'index_facebook_bot_activists_on_messages', 'messages', 'index on messages column');
    SELECT has_index('public', 'facebook_bot_activists', 'index_facebook_bot_activists_on_quick_replies', 'quick_replies', 'index on quick_replies column');
    SELECT has_index('public', 'facebook_bot_activists', 'index_facebook_bot_activists_on_recipient_id_and_sender_id', '{fb_context_recipient_id, fb_context_sender_id}'::text[], 'index on fb_context_recipient_id, fb_context_sender_id columns');
    SELECT index_is_unique('public', 'facebook_bot_activists', 'index_facebook_bot_activists_on_recipient_id_and_sender_id');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
