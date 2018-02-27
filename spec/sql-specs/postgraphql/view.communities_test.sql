begin;
  insert into public.users(id, email, provider, uid, encrypted_password, admin) values
  (1, 'foo@foo.com', 'bonde', '1', crypt('123456', gen_salt('bf', 9)), false);

  select plan(2);

  select has_view('postgraphql', 'communities', 'view returns communities to current_user');

  /* create or replace function test_get_communities_not_authenticate() */
  /* returns setof text language plpgsql as $$ */
  /* declare */
  /* begin */
  /*   set local role anonymous; */

  /*   return next throws_matching( */
  /*     'select postgraphql.communities', */
  /*     'permission_denied', */
  /*     'should be authenticated' */
  /*   ); */
  /* end; */
  /* $$; */
  /* select * from test_get_communities_not_authenticate(); */

  create or replace function test_get_communities()
  returns setof text language plpgsql as $$
  declare
  begin
    set jwt.claims.user_id = 1;
    set local role common_user;

    perform postgraphql.create_community(
      json_build_object(
        'name', 'Nossa BH',
        'city', 'Belo Horizonte')
    );

    perform postgraphql.create_community(
      json_build_object(
        'name', 'Nossa BH 2',
        'city', 'Belo Horizonte 2')
    );

    return next ok(
      (
        select count(1) from postgraphql.communities
      ) > 1,
      'should created communities from current_user');
  end;
  $$;
  select * from test_get_communities();
rollback;
