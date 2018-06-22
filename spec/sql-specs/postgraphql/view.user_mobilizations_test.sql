begin;

  select plan(3);

  -- insert basic data
  insert into public.users(id, email, provider, uid, encrypted_password, admin)
  values(1, 'foo@foo.com', 'bonde', 'foo@foo.com', crypt('12345678', gen_salt('bf', 9)), false);

  insert into public.communities(id, name, created_at, updated_at)
  values(1, 'Bonde Test', now(), now());

  insert into public.mobilizations(id, created_at, updated_at, name, community_id, slug)
  values
    (1, now(), now(), 'Mobi 1', 1, 'mob1_slug'),
    (2, now(), now(), 'Mobi 2', 1, 'mob2_slug'),
    (3, now(), now(), 'Mobi 3', 1, 'mob3_slug');


  insert into public.community_users(user_id, community_id, created_at, updated_at)
  values(1, 1, now(), now());

  select has_view('postgraphql', 'user_mobilizations', 'should have view defined');

  prepare get_user_mobilizations as select * from postgraphql.user_mobilizations limit 1;

  create or replace function test_with_authenticated_user()
  returns setof text language plpgsql as $$
  declare
    _user_mob postgraphql.user_mobilizations;
  begin
    set local role common_user;
    set jwt.claims.user_id = 1;
    select * from postgraphql.user_mobilizations limit 1
    into _user_mob;

    return next is(_user_mob.id is not null, true, 'returns mobilizations that the user has access to' );
    set local role postgres;
  end;
  $$;
  select * from test_with_authenticated_user();

  create or replace function test_with_non_authenticated_user()
  returns setof text language plpgsql as $$
  declare
  begin
    set local role anonymous;
    return next throws_matching('get_user_mobilizations', 'permission denied', 'should not permit non microservices role');
  end;
  $$;
  select * from test_with_non_authenticated_user();
rollback;
