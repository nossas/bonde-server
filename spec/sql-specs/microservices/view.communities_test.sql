BEGIN;
  insert into public.users(id, email, provider, uid, encrypted_password, admin)
  values (1, 'john@example.org', 'bonde', '1', crypt('12345678', gen_salt('bf', 9)), false);

  select plan(2);

  select has_view('microservices', 'communities', 'view returns all communities');

  create or replace function test_get_communities()
  returns setof text language plpgsql as $$
  declare
    _community public.communities;
  begin
    set jwt.claims.user_id = 1;
    set local role postgres;

    insert into public.communities(name, city, created_at, updated_at)
      values('Nossas BH', 'Belo Horizonte', now(), now())
    returning * into _community;

    insert into public.mobilizations(name, created_at, updated_at, community_id, custom_domain, slug)
    values('Mobi 01', now(), now(), _community.id, 'mobi01.example.org', 'slug-mob01');

    set local role microservices;

    return next ok(
      (
        select count(1) from microservices.communities
      ) >= 1,
      'should returns communities with mobilizations domains');
  end;
  $$;
  select * from test_get_communities();
ROLLBACK;
