BEGIN;
    SELECT plan(13);

    -- check table presence
    SELECT has_table('public'::name, 'community_activists'::name);

    -- check not nulls
    SELECT col_not_null('public', 'community_activists', 'id', 'should be not null');
    SELECT col_not_null('public', 'community_activists', 'community_id', 'should be not null');
    SELECT col_not_null('public', 'community_activists', 'activist_id', 'should be not null');
    SELECT col_not_null('public', 'community_activists', 'updated_at', 'should be not null');
    SELECT col_not_null('public', 'community_activists', 'created_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'community_activists', 'id', 'should be pk');

    SELECT fk_ok('public', 'community_activists', 'activist_id',
        'public', 'activists', 'id');

    SELECT fk_ok('public', 'community_activists', 'community_id',
        'public', 'communities', 'id');

    SELECT index_is_unique('public', 'community_activists', 'index_community_activists_on_community_id_and_activist_id');
    SELECT has_index('public', 'community_activists', 'index_community_activists_on_community_id_and_activist_id', '{community_id, activist_id}'::text[], 'index on activist_id, community_id columns');
    SELECT has_index('public', 'community_activists', 'index_community_activists_on_activist_id', 'activist_id', 'index on activist_id columns');
    SELECT has_index('public', 'community_activists', 'index_community_activists_on_community_id', 'community_id', 'index on community_id columns');


    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
