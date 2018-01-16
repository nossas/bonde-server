BEGIN;
    SELECT plan(7);

    -- check table presence
    SELECT has_table('public'::name, 'activist_tags'::name);

    -- check not nulls
    SELECT col_not_null('public', 'activist_tags', 'updated_at', 'should be not null');
    SELECT col_not_null('public', 'activist_tags', 'created_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'activist_tags', 'id', 'should be pk');

    SELECT fk_ok('public', 'activist_tags', 'activist_id',
        'public', 'activists', 'id');

    --SELECT fk_ok('public', 'activist_tags', 'mobilization_id',
    --    'public', 'mobilizations', 'id');

    SELECT fk_ok('public', 'activist_tags', 'community_id',
        'public', 'communities', 'id');

    SELECT has_index('public', 'activist_tags', 'index_activist_tags_on_activist_id_and_community_id_and_mob_id', '{activist_id, community_id, mobilization_id}'::text[], 'index on activist_id, community_id, mobilization_id columns');


    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
