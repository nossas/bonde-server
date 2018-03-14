BEGIN;
  insert into public.users(id, email, provider, uid, encrypted_password, admin)
  values (1, 'john@example.org', 'bonde', '1', crypt('12345678', gen_salt('bf', 9)), false);

  select plan(2);

  select has_view('microservices', 'dns_hosted_zones', 'view returns all dns_hosted_zones');

  create or replace function test_get_dns_hosted_zones()
  returns setof text language plpgsql as $$
  declare
    _community public.communities;
  begin
    set jwt.claims.user_id = 1;
    set local role postgres;

    insert into public.communities(name, city, created_at, updated_at)
    values('Nossas BH', 'Belo Horizonte', now(), now())
    returning * into _community;

    insert into public.dns_hosted_zones(community_id, domain_name, created_at, updated_at, ns_ok)
    values
      (_community.id, 'example.org', now(), now(), true),
      (_community.id, 'example2.org', now(), now(), true),
      (_community.id, 'example3.org', now(), now(), true);

    set local role microservices;

    return next ok(
      (
        select count(1) from microservices.dns_hosted_zones
      ) > 1,
      'should returns dns_hosted_zones');
  end;
  $$;
  select * from test_get_dns_hosted_zones();
ROLLBACK;
