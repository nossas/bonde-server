BEGIN;
    SELECT plan(7);

    -- check table presence
    SELECT has_table('public'::name, 'dns_hosted_zones'::name);

    -- check not nulls
    SELECT col_not_null('public', 'dns_hosted_zones', 'id', 'should be not null');
    SELECT col_not_null('public', 'dns_hosted_zones', 'created_at', 'should be not null');
    SELECT col_not_null('public', 'dns_hosted_zones', 'updated_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'dns_hosted_zones', 'id', 'should be pk');

    SELECT fk_ok('public', 'dns_hosted_zones', 'community_id',
        'public', 'communities', 'id');

    SELECT has_index('public', 'dns_hosted_zones', 'index_dns_hosted_zones_on_domain_name', 'domain_name', 'index on domain_name column');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
