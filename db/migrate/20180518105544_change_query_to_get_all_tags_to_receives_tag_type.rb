class ChangeQueryToGetAllTagsToReceivesTagType < ActiveRecord::Migration
  def up
    execute %Q{
create or replace view postgraphql.tags as
  select
    t.id,
    t.name,
    t.taggings_count,
    t.label,
    (regexp_split_to_array((t.name)::text, '_'::text))[1] AS tag_type
  from public.tags t;

grant select on public.tags to postgraphql, common_user, admin;
grant select on postgraphql.tags to postgraphql, common_user, admin;

}
  end

  def down
    execute %Q{
drop view postgraphql.tags;
}
  end
end
