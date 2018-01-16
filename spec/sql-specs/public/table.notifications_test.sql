BEGIN;
    SELECT plan(12);

    -- check table presence
    SELECT has_table('public'::name, 'notifications'::name);

    -- check not nulls
    SELECT col_not_null('public', 'notifications', 'id', 'should be not null');
    SELECT col_not_null('public', 'notifications', 'notification_template_id', 'should be not null');
    SELECT col_not_null('public', 'notifications', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'notifications', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'notifications', 'id', 'should be pk');

    -- check foreign keys
    SELECT fk_ok('public', 'notifications', 'community_id',
       'public', 'communities', 'id');

    SELECT fk_ok('public', 'notifications', 'notification_template_id',
       'public', 'notification_templates', 'id');

    SELECT fk_ok('public', 'notifications', 'activist_id',
       'public', 'activists', 'id');

    -- check indexes
    SELECT has_index('public', 'notifications', 'index_notifications_on_activist_id', 'activist_id', 'index on column');
    SELECT has_index('public', 'notifications', 'index_notifications_on_community_id', 'community_id', 'index on column');
    SELECT has_index('public', 'notifications', 'index_notifications_on_notification_template_id', 'notification_template_id', 'index on column');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
