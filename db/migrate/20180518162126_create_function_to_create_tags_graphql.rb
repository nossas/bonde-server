class CreateFunctionToCreateTagsGraphql < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function postgraphql.create_tags(name text, label text)
    RETURNS json
    LANGUAGE plpgsql
AS $function$
declare
    _tag public.tags;
    _user_tag public.user_tags;
begin
    if current_role = 'anonymous' then
        raise 'permission_denied';
    end if;

    if name is null then
        raise 'name_is_empty';
    end if;

    if label is null then
        raise 'label_is_empty';
    end if;

    insert into public.tags(name, label)
    values(concat('user_', name), label)
    returning * into _tag;

    -- insert a new tag in current_user
    insert into public.user_tags(user_id, tag_id, created_at, updated_at)
    values(postgraphql.current_user_id(), _tag.id, now(), now())
    returning * into _user_tag;

    return json_build_object(
        'msg', 'tag created successful',
        'tag_id', _tag.id,
        'user_tag', _user_tag.id
    );
end;
$function$;

grant execute on function postgraphql.create_tags(name text, label text) to common_user, admin, postgraphql;
grant insert, select, update on public.user_tags to common_user, admin, postgraphql;
grant usage on sequence user_tags_id_seq to common_user, admin;
grant insert, select, update on public.tags to common_user, admin, postgraphql;
grant usage on sequence tags_id_seq to common_user, admin;
}
  end

  def down
    execute %Q{
drop function postgraphql.create_tags(name text, label text);
}
  end
end
