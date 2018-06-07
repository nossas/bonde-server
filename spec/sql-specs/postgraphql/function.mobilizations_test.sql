begin;
  \i ./spec/sql-support/insert_basic_data.sql;

  select plan(3);

  select has_function('postgraphql', 'mobilizations', ARRAY['integer']);
  select function_returns('postgraphql', 'mobilizations', ARRAY['integer'], 'json');

  create or replace function test_get_trending_mobs_not_authenticated()
  returns setof text language plpgsql as $$
  declare
  begin
    set local role anonymous;

    return next throws_matching(
    'select * from postgraphql.mobilizations(2)',
    'permission_denied',
    'should be authenticated'
    );
  end;
  $$;
  select * from test_get_trending_mobs_not_authenticated();
rollback;
