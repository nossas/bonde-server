BEGIN;
    SELECT plan(9);

    -- check table presence
    SELECT has_table('public'::name, 'notification_templates'::name);

    -- check not nulls
    SELECT col_not_null('public', 'notification_templates', 'id', 'should be not null');
    SELECT col_not_null('public', 'notification_templates', 'label', 'should be not null');
    SELECT col_not_null('public', 'notification_templates', 'subject_template', 'should be not null');
    SELECT col_not_null('public', 'notification_templates', 'body_template', 'should be not null');
    SELECT col_not_null('public', 'notification_templates', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'notification_templates', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'notification_templates', 'id', 'should be pk');

    -- check foreign keys
    SELECT fk_ok('public', 'notification_templates', 'community_id',
       'public', 'communities', 'id');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
