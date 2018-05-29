class ChangeCreateUserTagsV2 < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION postgraphql.create_user_tags(data json)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
declare
    _tags json;
    _tag text;
begin
    if current_role = 'anonymous' then
        raise 'permission_denied';
    end if;

    for _tag in (select * from json_array_elements_text(($1->>'tags')::json))
    loop
        insert into public.user_tags(user_id, tag_id, created_at, updated_at)
        (
            select postgraphql.current_user_id(),
            (select id from public.tags where name = _tag),
            now(),
            now()
        ) returning * into _tags;
    end loop;

    return (select json_agg(t.name) from (
        select * from tags t
        left join user_tags ut on ut.tag_id = t.id
        where ut.user_id = (postgraphql.current_user_id())
    ) t);
end;
$function$;
}
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION postgraphql.create_user_tags(data json)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
declare
    _tags json;
    _tag text;
begin
    if current_role = 'anonymous' then
        raise 'permission_denied';
    end if;

    for _tag in (select * from json_array_elements_text(($1->>'tags')::json))
    loop
        insert into public.user_tags(user_id, tag_id, created_at, updated_at)
        (
            select postgraphql.current_user_id(),
            (select id from public.tags where name = _tag),
            now(),
            now()
        ) returning * into _tags;
    end loop;

    return json_build_object('msg','user tags created successfully');
end;
$function$
}
  end
end
