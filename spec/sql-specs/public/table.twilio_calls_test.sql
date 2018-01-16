BEGIN;
    SELECT plan(11);

    -- check table presence
    SELECT has_table('public'::name, 'twilio_calls'::name);

    -- check not nulls
    SELECT col_not_null('public', 'twilio_calls', 'id', 'should be not null');
    SELECT col_not_null('public', 'twilio_calls', 'from', 'should be not null');
    SELECT col_not_null('public', 'twilio_calls', 'to', 'should be not null');
    SELECT col_not_null('public', 'twilio_calls', 'data', 'should be not null');
    SELECT col_not_null('public', 'twilio_calls', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'twilio_calls', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'twilio_calls', 'id', 'should be pk');

    SELECT fk_ok('public', 'twilio_calls', 'widget_id', 'public', 'widgets', 'id');

    SELECT has_index('public', 'twilio_calls', 'index_twilio_calls_on_widget_id', 'widget_id', 'index on columns');

    SELECT triggers_are('public', 'twilio_calls', '{watched_twilio_call_trigger}'::text[]);

    SELECT * FROM finish();
ROLLBACK;
