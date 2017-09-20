class AddFilterToCommunityTags < ActiveRecord::Migration
def up
    execute %Q{
create or replace function postgraphql.filter_community_tags (search text, ctx_community_id int) returns setof postgraphql.community_tags as $$
  select * from postgraphql.community_tags
    where community_id = ctx_community_id
    and tag_complete_name ilike ('%' || search || '%')
$$ language sql stable;
comment on function postgraphql.filter_community_tags(text, int) is 'filter community_tags view by tag_complete_name and communityd_id';
}
  end

  def down
    execute %Q{
drop function  postgraphql.filter_community_tags() cascade;
}
  end
end
