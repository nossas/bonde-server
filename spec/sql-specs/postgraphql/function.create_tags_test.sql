begin;
  insert into public.users(id, email, provider, uid, encrypted_password, admin)
  values(1, 'foo@foo.com', 'bonde', '1', crypt('123456', gen_salt('bf', 9)), false);

  select plan(6);

  select has_function('postgraphql', 'create_tags', ARRAY['text', 'text']);
  select function_returns('postgraphql', 'create_tags', ARRAY['text', 'text'], 'json');

  create or replace function test_create_tags_not_auth()
  returns setof text language plpgsql as $$
  declare
  begin
  set local role anonymous;

  return next throws_matching(
    'select postgraphql.create_tags(''nosass-hudson-test'', ''Nossas Hudson Test'');',
    'permission_denied',
    'should be authenticated'
  );
  end;
  $$;
  select * from test_create_tags_not_auth();

  create or replace function test_create_tags()
  returns setof text language plpgsql as $$
  declare
    _result json;
    _tag public.tags;
    _user_tag public.user_tags;
  begin
    set jwt.claims.user_id = 1;
    set local role common_user;

    _result := postgraphql.create_tags('nossas-example','Nossas Example');

    select * from public.tags where name = 'user_nossas-example'
    into _tag;

    select * from public.user_tags where tag_id = _tag.id and user_id = postgraphql.current_user_id()
    into _user_tag;

    return next is(_result->>'msg', 'tag created successful', 'check msg for created tag');

    return next is((_result->>'tag_id')::text, (_tag.id)::text, 'check tag_id');

    return next is((_result->>'user_tag')::text, (_user_tag.id)::text, 'check user_tag_id');
  end;
  $$;
  select * from test_create_tags();
rollback;
