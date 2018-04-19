begin;
  insert into public.users(id, email, provider, uid, encrypted_password, admin) values
    (1, 'foo@foo.com', 'bonde', '1', crypt('123456', gen_salt('bf', 9)), false);

  select plan(8);

  select has_function('postgraphql', 'create_community', ARRAY['json']);
  select function_returns('postgraphql', 'create_community', ARRAY['json'], 'json');

  create or replace function test_create_community_not_authenticated()
  returns setof text language plpgsql as $$
  declare
  begin
    set local role anonymous;

    return next throws_matching(
    'select postgraphql.create_community(''{"name": "Nossa BH", "city": "Belo Horizonte"}''::json)',
      'permission_denied',
      'should be authenticated'
    );
  end;
  $$;
  select * from test_create_community_not_authenticated();

  create or replace function test_create_community_authenticated()
  returns setof text language plpgsql as $$
  declare
    _community json;
  begin
    set jwt.claims.user_id = 1;
    set local role common_user;

    -- test missing requied attributes
    return next throws_matching(
      'select postgraphql.create_community(''{"name": "", "city": "Belo Horizonte"}''::json)',
      'missing_community_name',
      'should be raise when missing community name'
    );
    return next throws_matching(
      'select postgraphql.create_community(''{"name": "Nossa BH", "city": ""}''::json)',
      'missing_community_city',
      'should be raise when missing community city'
    );

    _community := postgraphql.create_community(
      json_build_object(
        'name', 'Nossa BH',
        'city', 'Belo Horizonte')
    );
    return next is(_community->>'name', 'Nossa BH', 'should community name equals Nossa BH');
    return next is(_community->>'city', 'Belo Horizonte', 'should community city equals Belo Horizonte');

    return next ok(
      (
        select count(1) from public.community_users
        where user_id = postgraphql.current_user_id() and community_id = (_community->>'id')::int
      ) > 0,
      'should create community_users after create a new community');
  end;
  $$;
  select * from test_create_community_authenticated();
rollback;
