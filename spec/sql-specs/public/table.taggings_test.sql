BEGIN;
    SELECT plan(14);

    -- check table presence
    SELECT has_table('public'::name, 'taggings'::name);

    -- check not nulls
    SELECT col_not_null('public', 'taggings', 'id', 'should be not null');

    -- check column constraints / indexes
    SELECT col_is_pk('public', 'taggings', 'id', 'should be pk');

    -- SELECT fk_ok('public', 'taggings', 'tag_id',
    --     'public', 'tags', 'id');

    SELECT has_index('public', 'taggings', 'index_taggings_on_context', 'context', 'index on context column');
    SELECT has_index('public', 'taggings', 'index_taggings_on_tag_id', 'tag_id', 'index on tag_id column');
    SELECT has_index('public', 'taggings', 'index_taggings_on_taggable_id', 'taggable_id', 'index on taggable_id column');
    SELECT has_index('public', 'taggings', 'index_taggings_on_taggable_id_and_taggable_type', '{taggable_id, taggable_type}'::text[], 'index on taggable_id, taggable_type columns');
    SELECT has_index('public', 'taggings', 'index_taggings_on_taggable_id_and_taggable_type_and_context', '{taggable_id, taggable_type, context}'::text[], 'index on taggable_id, taggable_type, context columns');
    SELECT has_index('public', 'taggings', 'index_taggings_on_taggable_type', 'taggable_type', 'index on taggable_type column');
    SELECT has_index('public', 'taggings', 'index_taggings_on_tagger_id', 'tagger_id', 'index on tagger_id column');
    SELECT has_index('public', 'taggings', 'index_taggings_on_tagger_id_and_tagger_type', '{tagger_id, tagger_type}'::text[], 'index on tagger_id, tagger_type column');
    SELECT has_index('public', 'taggings', 'taggings_idx', '{tag_id,taggable_id,taggable_type,context,tagger_id,tagger_type}'::text[], 'index on tag_id,taggable_id,taggable_type,context,tagger_id,tagger_type columns');
    SELECT has_index('public', 'taggings', 'taggings_idy', '{taggable_id,taggable_type,tagger_id,context}'::text[], 'index on taggable_id,taggable_type,tagger_id,context columns');

    SELECT index_is_unique('public', 'taggings', 'taggings_idx');

    -- Finish the tests and clean up.
    SELECT * FROM finish();
ROLLBACK;
