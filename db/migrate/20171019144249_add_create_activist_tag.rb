class AddCreateActivistTag < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function postgraphql.create_activist_tag(data json)
    returns json
    language plpgsql
    volatile
    as $$
        declare
            _activist public.activists;
            _tagging public.taggings;
            _tag public.tags;
            _activist_tag public.activist_tags;
            _community_id integer;
            --_mobilization public.mobilizations;            
        begin
            -- check for community_id
            _community_id := ($1->>'community_id')::integer;
            if _community_id is null then
                raise 'missing community_id inside activist';
            end if;            

            -- check if current_user has participation on this community or he is admin
            if not postgraphql.current_user_has_community_participation(_community_id) and current_role <> 'admin' then
                raise 'operation not permitted';
            end if;
            
            -- get mobilization
            -- select * from public.mobilizations
            --     where community_id = _community_id
            --         and id = ($1->>'mobilization_id')::integer
            --     into _mobilization;
            
            -- get activist
            select * from public.activists a
                where a.id = ($1->>'activist_id')::integer
                limit 1 into _activist;
                
            -- check if activists in community
            if not exists(select true from community_activists 
                where community_id = _community_id
                    and activist_id = _activist.id) then
                raise 'activist not found on community';
            end if;
            
            -- insert new activist_tag
            select * from public.activist_tags 
                where activist_id = _activist.id 
                    and community_id = _community_id
                into _activist_tag;

            if _activist_tag is null then
                insert into public.activist_tags (activist_id, community_id, created_at, updated_at)
                    values (_activist.id, _community_id, now(), now())
                    returning * into _activist_tag;
            end if;
                
            -- search for some tag that have the same name
            select * from public.tags
                where name = 'input_'||public.slugfy(($1->>'name')::text)
                limit 1
                into _tag;

            -- insert tag if not found
            if _tag is null then
                insert into public.tags (name, label) 
                    values ('input_'||public.slugfy(($1->>'name')::text), ($1->>'name')::text)
                    returning * into _tag;
            end if;
            
            -- create taggings linking activist_tag to tag
            select * from public.taggings
                where tag_id = _tag.id
                    and taggable_id = _activist_tag.id
                    and taggable_type = 'ActivistTag'
                into _tagging;
            if _tagging is null then
                insert into public.taggings(tag_id, taggable_id, taggable_type) 
                    values (_tag.id, _activist_tag.id, 'ActivistTag')
                    returning * into _tagging;
            end if;
            
            return json_build_object(
                'activist_tag_id', _activist_tag.id,
                'tag_id', _tag.id,
                'activist_id', _activist.id,
                'tag_name', _tag.name,
                'tag_label', _tag.label
            );
        end;
    $$;

grant select, insert on public.activist_tags to common_user, admin;
grant select, insert on public.tags to common_user, admin;
grant select, insert on public.taggings to common_user, admin;
grant usage on sequence public.activist_tags_id_seq to common_user, admin;
grant usage on sequence public.tags_id_seq to common_user, admin;
grant usage on sequence public.taggings_id_seq to common_user, admin;
}
  end

  def down
    execute %Q{
drop function postgraphql.create_activist_tag(data json);
}
  end
end
