BEGIN;
    SELECT plan(11);

    -- check table presence
    SELECT has_table('public'::name, 'twilio_configurations'::name);

    -- check not nulls
    SELECT col_not_null('public', 'twilio_configurations', 'id', 'should be not null');
    SELECT col_not_null('public', 'twilio_configurations', 'community_id', 'should be not null');
    SELECT col_not_null('public', 'twilio_configurations', 'twilio_account_sid', 'should be not null');
    SELECT col_not_null('public', 'twilio_configurations', 'twilio_auth_token', 'should be not null');
    SELECT col_not_null('public', 'twilio_configurations', 'twilio_number', 'should be not null');
    SELECT col_not_null('public', 'twilio_configurations', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'twilio_configurations', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'twilio_configurations', 'id', 'should be pk');

    -- SELECT fk_ok('public', 'twilio_configurations', 'community_id', 'public', 'communities', 'id');

    SELECT has_index('public', 'twilio_configurations', 'index_twilio_configurations_on_community_id', 'community_id', 'index on columns');
    SELECT index_is_unique('public', 'twilio_configurations', 'index_twilio_configurations_on_community_id');

    SELECT * FROM finish();
ROLLBACK;
