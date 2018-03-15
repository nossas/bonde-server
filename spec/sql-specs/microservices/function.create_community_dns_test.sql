BEGIN;
  insert into public.users(id, email, provider, uid, encrypted_password, admin)
  values (1, 'john@example.org', 'bonde', '1', crypt('12345678', gen_salt('bf', 9)), false);

  select plan(6);

  select has_function('microservices', 'create_community_dns', ARRAY['json']);
  select function_returns('microservices', 'create_community_dns', ARRAY['json'], 'json');

  create or replace function test_create_community_dns()
  returns setof text language plpgsql as $$
  declare
    _community public.communities;
    _dns_hosted_zone public.dns_hosted_zones;
    _dns_response json;
  begin
    set jwt.claims.user_id = 1;
    set local role postgres;

    insert into public.communities(name, city, created_at, updated_at)
    values('Nossas BH', 'Belo Horizonte', now(), now())
    returning * into _community;

    -- test success change
    set local role microservices;
    _dns_response := microservices.create_community_dns(json_build_object(
        'community_id', _community.id,
        'domain_name', 'community.domain.org',
        'comment', 'comment from domain'
    ));

    return next is((_dns_response->>'community_id')::integer, _community.id, 'should community id equals a community current');
    return next is(_dns_response->>'domain_name', 'community.domain.org', 'should community domain equals community.domain.org');
    return next is(_dns_response->>'comment', 'comment from domain', 'should comentary from community');
    return next is((_dns_response->>'ns_ok')::boolean, false, 'should ns_ok is null');

    set local role postgres;
  end;
  $$;
  select * from test_create_community_dns();
ROLLBACK;
