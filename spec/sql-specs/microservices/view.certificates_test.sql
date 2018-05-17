BEGIN;
  insert into public.users(id, email, provider, uid, encrypted_password, admin)
  values (1, 'john@example.org', 'bonde', '1', crypt('12345678', gen_salt('bf', 9)), false);

  select plan(4);

  select has_view('microservices', 'certificates', 'view returns all certificates actives');

  insert into public.certificates (community_id, mobilization_id, dns_hosted_zone_id, domain, is_active, created_at, updated_at)
    values
      (1, 1, 1, 'example.org', true, now(), now()),
      (1, 1, 1, 'example2.org', true, now(), now()),
      (1, 1, 1, 'example3.org', true, now(), now());

  prepare get_certificates as select * from microservices.certificates;

  create or replace function test_get_certificates()
  returns setof text language plpgsql as $$
  declare
  begin
    set jwt.claims.user_id = 1;


    return next ok(
      (
        select count(1) from microservices.certificates
      ) > 1,
      'should returns all actives certificates');
    set local role postgres;
  end;
  $$;

  create or replace function test_with_non_microservices_role()
  returns setof text language plpgsql as $$
  declare
  begin
    set jwt.claims.user_id = 1;
    set local role anonymous;
    return next throws_matching('get_certificates', 'permission denied for schema microservices', 'should not permit non microservices role');

    set local role common_user;
    return next throws_matching('get_certificates', 'permission denied for schema microservices', 'should not permit non microservices role');

    set local role admin;
    return next throws_matching('get_certificates', 'permission denied', 'should not permit non microservices role');
  end;
  $$;
  select * from test_with_non_microservices_role();
ROLLBACK;
