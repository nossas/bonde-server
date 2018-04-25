BEGIN;
  insert into public.users(id, email, provider, uid, encrypted_password, admin)
  values (1, 'john@example.org', 'bonde', '1', crypt('12345678', gen_salt('bf', 9)), false);

  select plan(5);

  select has_view('microservices'::name, 'communities'::name, 'view returns all communities');

  insert into public.communities(name, city, created_at, updated_at)
  values('Nossas BH', 'Belo Horizonte', now(), now());

  insert into public.mobilizations(name, created_at, updated_at, community_id, custom_domain, slug)
  values('Mobi 01', now(), now(), (select id from public.communities where name = 'Nossas BH') , 'mobi01.example.org', 'slug-mob01');

  prepare get_communities as select * from microservices.communities;

  create or replace function test_get_communities()
  returns setof text language plpgsql as $$
  declare
  begin
    set jwt.claims.user_id = 1;
    set local role microservices;

    return next ok(
      (
        select count(1) from microservices.communities
      ) >= 1,
      'should returns communities with mobilizations domains');
    set local role postgres;
  end;
  $$;
  select * from test_get_communities();

  create or replace function test_with_non_microservices_role()
  returns setof text language plpgsql as $$
  declare
  begin
    set jwt.claims.user_id = 1;
    set local role anonymous;
    return next throws_matching('get_communities', 'permission denied for schema microservices', 'should not permit non microservices role');

    set local role common_user;
    return next throws_matching('get_communities', 'permission denied for schema microservices', 'should not permit non microservices role');

    set local role admin;
    return next throws_matching('get_communities', 'permission denied', 'should not permit non microservices role');
  end;
  $$;
  select * from test_with_non_microservices_role();
ROLLBACK;
