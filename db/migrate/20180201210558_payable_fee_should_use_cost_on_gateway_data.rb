class PayableFeeShouldUseCostOnGatewayData < ActiveRecord::Migration
  def up
    execute %Q{
    CREATE OR REPLACE FUNCTION public.payable_fee(d donations)
 RETURNS numeric
 LANGUAGE sql
 IMMUTABLE
AS $function$
    select (
    case
    when d.payables is not null and jsonb_array_length(d.payables) < 2 then
        (
            case 
            when extract(year from d.created_at) <= 2016 then        
                (((d.payables -> 0 ->> 'amount')::integer / 100.0) * 0.15)  - ((d.payables -> 0 ->> 'fee')::integer / 100.0)
            else
                (((d.payables -> 0 ->> 'amount')::integer / 100.0) * 0.13) - ((d.payables -> 0 ->> 'fee')::integer / 100.0)
            end
        )
    when d.payables is null then
        (
            case 
            when extract(year from d.created_at) <= 2016 then
                (d.amount / 100.0) * 0.15
            else
                (d.amount / 100.0) * 0.13
            end        
        )    
    else
        (
            select 
                ((p ->> 'amount')::integer / 100.0) - ((p ->> 'fee')::integer / 100.0)
            from jsonb_array_elements(d.payables) p
                where (p ->> 'fee')::integer <> 0
                    limit 1
        )
    end)::decimal - (case d.payment_method 
                     when 'boleto' then 0
                     else coalesce(((d.gateway_data ->> 'cost')::integer / 100.0), 0) end)
$function$
;
}
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION public.payable_fee(d donations)
 RETURNS numeric
 LANGUAGE sql
 IMMUTABLE
AS $function$
    select (
    case
    when d.payables is not null and jsonb_array_length(d.payables) < 2 then
        (
            case 
            when extract(year from d.created_at) <= 2016 then        
                (((d.payables -> 0 ->> 'amount')::integer / 100.0) * 0.15)  - ((d.payables -> 0 ->> 'fee')::integer / 100.0)
            else
                (((d.payables -> 0 ->> 'amount')::integer / 100.0) * 0.13) - ((d.payables -> 0 ->> 'fee')::integer / 100.0)
            end
        )
    when d.payables is null then
        (
            case 
            when extract(year from d.created_at) <= 2016 then
                (d.amount / 100.0) * 0.15
            else
                (d.amount / 100.0) * 0.13
            end        
        )    
    else
        (
            select 
                ((p ->> 'amount')::integer / 100.0) - ((p ->> 'fee')::integer / 100.0)
            from jsonb_array_elements(d.payables) p
                where (p ->> 'fee')::integer <> 0
                    limit 1
        )
    end)::decimal
$function$
;
}
  end
end
