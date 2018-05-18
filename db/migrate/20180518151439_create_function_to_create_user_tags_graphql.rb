class CreateFunctionToCreateUserTagsGraphql < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function postgraphql.create_user_tags(data json)
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
$function$;

grant execute on function postgraphql.create_user_tags(json) to common_user, admin, postgraphql;
grant insert, select, update on public.user_tags to common_user, admin, postgraphql;
grant usage on sequence user_tags_id_seq to common_user, admin;

}
  end

  def down
    execute %Q{
drop function postgraphql.create_user_tags(data json);
}
  end
end
