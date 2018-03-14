BEGIN;
  insert into public.users(id, email, provider, uid, encrypted_password, admin)
  values (1, 'john@example.org', 'bonde', '1', crypt('12345678', gen_salt('bf', 9)), false);

  select plan(1);

  select has_view('microservices', 'certificates', 'view returns all certificates actives');

  create or replace function test_get_certificates()
  returns setof text language plpgsql as $$
  declare
  begin
    set jwt.claims.user_id = 1;
    set local role postgres;

    insert into public.certificates (community_id, mobilization_id, dns_hosted_zones_id, domain, is_active, created_at, updated_at)
    values
      (1, 1, 1, 'example.org', true, now(), now()),
      (1, 1, 1, 'example2.org', true, now(), now()),
      (1, 1, 1, 'example3.org', true, now(), now());

    return next ok(
      (
        select count(1) from microservices.certificates
      ) > 1,
      'should returns all actives certificates');
  end;
  $$;
ROLLBACK;
