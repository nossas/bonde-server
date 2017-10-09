class AdjustIndexesOnActivistTags < ActiveRecord::Migration
  def up
    execute %Q{
DROP INDEX IF EXISTS index_activist_tags_on_activist_id_and_community_id;
CREATE UNIQUE INDEX index_activist_tags_on_activist_id_and_community_id_and_mob_id ON activist_tags(activist_id, community_id, mobilization_id)
}
  end

  def down
    execute %Q{
    DROP INDEX IF EXISTS index_activist_tags_on_activist_id_and_community_id_and_mob_id;
CREATE UNIQUE INDEX index_activist_tags_on_activist_id_and_community_id ON activist_tags(activist_id, community_id)
}
  end
end
