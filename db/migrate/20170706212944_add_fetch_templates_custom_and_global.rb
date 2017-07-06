class AddFetchTemplatesCustomAndGlobal < ActiveRecord::Migration
  def change
    execute %Q{
      create or replace function postgraphql.global_templates()
        returns setof public.template_mobilizations as $$
          select *
          from public.template_mobilizations
          where
            global = true
        $$ language sql stable;

      create or replace function postgraphql.custom_templates(community_id integer)
        returns setof public.template_mobilizations as $$
          select *
          from public.template_mobilizations
          where community_id = community_id
          and global = false
      $$ language sql stable;

      grant select on table public.template_mobilizations TO common_user;
    }
  end
end
