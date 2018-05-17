begin;
  insert into public.users(id, email, provider, uid, encrypted_password, admin)
    values(1, 'foo@foo.com', 'bonde', '1', crypt('12345678', gen_salt('bf', 9)), false);

  select plan(3);

  select has_view('postgraphql', 'tags', 'views returns all tags');

  insert into public.tags(name,label)
    values
      ('bonde-example', 'Bonde Example');

  prepare get_tags as select * from postgraphql.tags;

  create or replace function test_get_tags()
  returns setof text language plpgsql as $$
  declare
    _tags postgraphql.tags;
  begin
    set jwt.claims.user_id = 1;
    set local role common_user;

    select * from postgraphql.tags limit 1
    into _tags;

    return next is(_tags.name, 'bonde-example');
  end;
  $$;
  select * from test_get_tags();

  create or replace function test_not_authenticated()
  returns setof text language plpgsql as $$
  declare
    _tags postgraphql.tags;
  begin
    set jwt.claims.user_id = 1;
    set local role anonymous;
    return next throws_matching('get_tags', 'permission denied for relation tags', 'should not pertmit non anonymous role');
  end;
  $$;
  select * from test_not_authenticated();
rollback;
