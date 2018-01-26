BEGIN;
    SELECT plan(8);

    -- check table presence
    SELECT has_table('public'::name, 'activist_matches'::name);

    -- check not nulls
    SELECT col_not_null('public', 'activist_matches', 'updated_at', 'should be not null');
    SELECT col_not_null('public', 'activist_matches', 'created_at', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'activist_matches', 'id', 'should be pk');

    SELECT fk_ok('public', 'activist_matches', 'activist_id',
        'public', 'activists', 'id');

    SELECT fk_ok('public', 'activist_matches', 'match_id',
        'public', 'matches', 'id');

    SELECT has_index('public', 'activist_matches', 'index_activist_matches_on_activist_id', 'activist_id', 'index on activist_id column');
    SELECT has_index('public', 'activist_matches', 'index_activist_matches_on_match_id', 'match_id', 'index on match_id');


    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
