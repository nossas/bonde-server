BEGIN;
    SELECT plan(12);

    -- check table presence
    SELECT has_table('public'::name, 'twilio_call_transitions'::name);

    -- check not nulls
    SELECT col_not_null('public', 'twilio_call_transitions', 'id', 'should be not null');
    SELECT col_not_null('public', 'twilio_call_transitions', 'twilio_account_sid', 'should be not null');
    SELECT col_not_null('public', 'twilio_call_transitions', 'twilio_call_sid', 'should be not null');
    SELECT col_not_null('public', 'twilio_call_transitions', 'sequence_number', 'should be not null');
    SELECT col_not_null('public', 'twilio_call_transitions', 'status', 'should be not null');
    SELECT col_not_null('public', 'twilio_call_transitions', 'called', 'should be not null');
    SELECT col_not_null('public', 'twilio_call_transitions', 'caller', 'should be not null');
    SELECT col_not_null('public', 'twilio_call_transitions', 'data', 'should be not null');
    SELECT col_not_null('public', 'twilio_call_transitions', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'twilio_call_transitions', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'twilio_call_transitions', 'id', 'should be pk');


    SELECT * FROM finish();
ROLLBACK;
