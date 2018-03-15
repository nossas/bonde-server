BEGIN;
  insert into public.users(id, email, provider, uid, encrypted_password, admin)
  values (1, 'john@example.org', 'bonde', '1', crypt('12345678', gen_salt('bf', 9)), false);

  select plan(5);
  select has_view('microservices', 'dns_hosted_zones', 'view returns all dns_hosted_zones');

  insert into public.communities(name, city, created_at, updated_at)
    values('Nossas BH', 'Belo Horizonte', now(), now());

  insert into public.dns_hosted_zones(community_id, domain_name, created_at, updated_at, ns_ok)
    values
    ((select id from public.communities where name = 'Nossas BH'), 'example.org', now(), now(), true),
    ((select id from public.communities where name = 'Nossas BH'), 'example2.org', now(), now(), true),
    ((select id from public.communities where name = 'Nossas BH'), 'example3.org', now(), now(), true);

  prepare get_dns_hosted_zones as select * from microservices.dns_hosted_zones;

  create or replace function test_get_dns_hosted_zones()
  returns setof text language plpgsql as $$
  declare
  begin
    set jwt.claims.user_id = 1;
    set local role microservices;

    return next ok(
      (
        select count(1) from microservices.dns_hosted_zones
      ) > 1,
      'should returns dns_hosted_zones');
    set local role postgres;
  end;
  $$;
  select * from test_get_dns_hosted_zones();

  create or replace function test_with_non_microservices_role()
  returns setof text language plpgsql as $$
  declare
  begin
    set jwt.claims.user_id = 1;
    set local role anonymous;
    return next throws_matching('get_dns_hosted_zones', 'permission denied for schema microservices', 'should not permit non microservices role');

    set local role common_user;
    return next throws_matching('get_dns_hosted_zones', 'permission denied for schema microservices', 'should not permit non microservices role');

    set local role admin;
    return next throws_matching('get_dns_hosted_zones', 'permission denied', 'should not permit non microservices role');
  end;
  $$;
  select * from test_with_non_microservices_role();
ROLLBACK;
