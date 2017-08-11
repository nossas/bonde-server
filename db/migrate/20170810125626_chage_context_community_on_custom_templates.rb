class ChageContextCommunityOnCustomTemplates < ActiveRecord::Migration
  def change
    execute %Q{
    drop function if exists postgraphql.custom_templates(community_id integer);
    create or replace function postgraphql.custom_templates (ctx_community_id integer)
      returns setof template_mobilizations as $$
        select *
          from public.template_mobilizations
          where community_id = ctx_community_id
          and global = false
          and postgraphql.current_user_has_community_participation(ctx_community_id);
      $$ language sql stable;
    }
  end
end
