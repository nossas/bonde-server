begin;

  \i /spec/sql-support/insert_basic_data.sql;

  select plan(7);

  select has_function('public'::name, 'generate_notification_tags'::name, ARRAY['json']);

  select function_returns('public'::name, 'generate_notification_tags'::name, ARRAY['json'], 'json');

  create or replace function test_generate_tags_for_donation()
  returns setof text language plpgsql as $$
    declare
      _donation public.donations;
      _activist public.activists;
      _result json;
    begin
      -- insert donation with payables
      insert into donations(activist_id, cached_community_id, widget_id, amount, payment_method, created_at, updated_at)
          values (__demo_activist_id(), __demo_community_id(), __demo_widget_id(), 1000, 'credit_card', now(), now())
          returning * into _donation;

      _result := public.generate_notification_tags(json_build_object(
        'donation_id', _donation.id
      ));

      return next is(_result->'community'->>'name', 'demo_com', 'check for community name inside tags');
      return next is(_result->'customer'->>'name', 'test full name', 'check for customer (activist) full name');
      return next is((_result->>'amount')::integer, 10, 'check for amount converted');
      return next is(_result->>'payment_method', 'credit_card', 'check for payment_method');
      return next is((_result->>'donation_id')::integer, _donation.id, 'check for donation id');
    end;
  $$;
  select test_generate_tags_for_donation();
rollback;
