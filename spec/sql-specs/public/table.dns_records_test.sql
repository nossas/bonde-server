BEGIN;
    SELECT plan(7);

    -- check table presence
    SELECT has_table('public'::name, 'dns_records'::name);

    -- check not nulls
    SELECT col_not_null('public', 'dns_records', 'id', 'should be not null');
    SELECT col_not_null('public', 'dns_records', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'dns_records', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'dns_records', 'id', 'should be pk');

    SELECT fk_ok('public', 'dns_records', 'dns_hosted_zone_id',
        'public', 'dns_hosted_zones', 'id');

    SELECT has_index('public', 'dns_records', 'index_dns_records_on_name_and_record_type', '{name, record_type}'::text[], 'index on name, record_type column');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
