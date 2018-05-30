begin;
  insert into public.users(id, email, provider, uid, encrypted_password, admin)
  values(1, 'foo@foo.com', 'bonde', '1 ', crypt('123456', gen_salt('bf', 9)), false);

  insert into public.tags(name, label)
  values
  ('user_nossas-label','Nossas Label'),
  ('user_bonde-label','Bonde Label'),
  ('user_meu-rio-label','Meu Rio Label'),
  ('user_minha-sampa-label','Minha Sampa Label');

  select plan(4);

  select has_function('postgraphql', 'create_user_tags', ARRAY['json']);
  select function_returns('postgraphql', 'create_user_tags', ARRAY['json'], 'json');

  create or replace function test_create_user_tags_not_authenticated()
  returns setof text language plpgsql as $$
  declare
  begin
    set local role anonymous;

    return next throws_matching(
    'select postgraphql.create_user_tags(''{"tags": ["form_escolas-democr-ticas", "pressure_juntos-pelo-parque-augusta", "form_mapa-do-acolhimento"]}''::json)',
    'permission_denied',
    'should be authenticated'
    );
  end;
  $$;
  select * from test_create_user_tags_not_authenticated();

  create or replace function test_create_user_tags_as_valid()
  returns setof text language plpgsql as $$
  declare
    _result json;
  begin
    set jwt.claims.user_id = 1;
    set local role common_user;

    _result := postgraphql.create_user_tags(
      json_build_object(
        'tags', json_build_array('user_nossas-label', 'user_bonde-label')
      )
    );

    return next is(_result->>0, 'user_nossas-label', 'check created user tags');
  end;
  $$;
  select * from test_create_user_tags_as_valid();
rollback;
