BEGIN;
    select plan(7);

    select function_returns('public', 'payable_fee', ARRAY['donations'], 'numeric');

    create or replace function test_donations_with_split()
    returns setof text language plpgsql as $$
        declare
            _donation public.donations;
        begin

            -- insert donation with payables
            insert into donations(payment_method, created_at, updated_at, payables, gateway_data)
                values ('credit_card', now(), now(), json_build_array(
                    json_build_object(
                        'id', 'payable_id_1',
                        'fee', 0,
                        'amount', 1000
                    ),
                    json_build_object(
                        'id', 'payable_id_2_tax',
                        'fee', 45,
                        'amount', 8700
                    )
                )::jsonb,
                json_build_object('cost', 50)::jsonb)
                returning * into _donation;

            return next is(
              public.payable_fee(_donation), 
              (8700/100.0)::decimal - (45/100.0)::decimal - (50/100.0)::decimal,
              'should use payable that have fee charged'
            );

            -- insert donation boleto with payables
            insert into donations(payment_method, created_at, updated_at, payables, gateway_data)
                values ('boleto', now(), now(), json_build_array(
                    json_build_object(
                        'id', 'payable_id_1',
                        'fee', 0,
                        'amount', 1000
                    ),
                    json_build_object(
                        'id', 'payable_id_2_tax',
                        'fee', 45,
                        'amount', 8700
                    )
                )::jsonb,
                json_build_object('cost', 50)::jsonb)
                returning * into _donation;

            return next is(
              public.payable_fee(_donation), 
              (8700/100.0)::decimal - (45/100.0)::decimal,
              'should use payable that have fee charged'
            );

        end;
    $$;
    select * from test_donations_with_split();

    create or replace function test_donations_with_one_payable()
    returns setof text language plpgsql as $$
        declare
            _donation public.donations;
        begin
            -- insert donation with payables
            insert into donations(payment_method, amount, created_at, updated_at, payables, gateway_data)
                values ('credit_card', 1000, now(), now(), json_build_array(
                    json_build_object(
                        'id', 'payable_id_1',
                        'fee', 45,
                        'amount', 1000
                    )
                )::jsonb,
                json_build_object('cost', 50)::jsonb)
                returning * into _donation;

            return next is(
                public.payable_fee(_donation),
                ((1000*0.13)/100.0)::decimal - (45/100.0) - (50/100.0)::decimal,
                'shoul calculate 13% of tax over donation amount'
            );

            -- insert donation with payables with boleto
            insert into donations(payment_method, amount, created_at, updated_at, payables, gateway_data)
                values ('boleto', 1000, now(), now(), json_build_array(
                    json_build_object(
                        'id', 'payable_id_1',
                        'fee', 45,
                        'amount', 1000
                    )
                )::jsonb,
                json_build_object('cost', 50)::jsonb)
                returning * into _donation;

            return next is(
                public.payable_fee(_donation),
                ((1000*0.13)/100.0)::decimal - (45/100.0),
                'shoul calculate 13% of tax over donation amount'
            );

            -- insert donation with payables into 2016
            insert into donations(payment_method, amount, created_at, updated_at, payables, gateway_data)
                values ('credit_card', 1000, '01-01-2016'::timestamp, now(), json_build_array(
                    json_build_object(
                        'id', 'payable_id_1',
                        'fee', 0,
                        'amount', 1000
                    )
                )::jsonb,
                json_build_object('cost', 50)::jsonb)
                returning * into _donation;

            return next is(
                public.payable_fee(_donation),
                ((1000*0.15)/100.0)::decimal - (50/100.0)::decimal,
                'shoul calculate 15% of tax over older(<=2016) donation amount'
            );

            -- insert donation with payables in 2016 with boleto
            insert into donations(payment_method, amount, created_at, updated_at, payables, gateway_data)
                values ('boleto', 1000, '01-01-2016'::timestamp, now(), json_build_array(
                    json_build_object(
                        'id', 'payable_id_1',
                        'fee', 0,
                        'amount', 1000
                    )
                )::jsonb,
                json_build_object('cost', 50)::jsonb)
                returning * into _donation;

            return next is(
                public.payable_fee(_donation),
                ((1000*0.15)/100.0)::decimal,
                'shoul calculate 15% of tax over older(<=2016) donation amount'
            );
        end;
    $$;
    select * from test_donations_with_one_payable();

    select * from finish();
ROLLBACK;
