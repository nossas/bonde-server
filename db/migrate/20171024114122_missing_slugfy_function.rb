class MissingSlugfyFunction < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function public.slugfy(text) returns text
    language sql
    immutable
    as $$
        select regexp_replace(replace(unaccent(lower($1)), ' ', '-'), '[^a-z0-9\-_]+', '', 'g');
    $$;
}
  end

  def down
    execute %Q{
drop function public.slugfy(text);
}
  end
end
