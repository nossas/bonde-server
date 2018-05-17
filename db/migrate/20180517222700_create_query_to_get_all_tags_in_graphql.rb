class CreateQueryToGetAllTagsInGraphql < ActiveRecord::Migration
  def up
    execute %Q{
create or replace view postgraphql.tags as
  select
    t.id,
    t.name,
    t.taggings_count,
    t.label
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
