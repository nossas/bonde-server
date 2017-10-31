class AdjustsCreateActivists < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION postgraphql.create_activist(activist json)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
        declare
            _activist public.activists;
            _community_id integer;
            _mobilization public.mobilizations;
        begin
            _community_id := ($1->>'community_id')::integer;

            if _community_id is null then
                raise 'missing community_id inside activist';
            end if;            

            if not postgraphql.current_user_has_community_participation(_community_id) then
                raise 'operation not permitted';
            end if;

            select * from public.mobilizations
                where community_id = _community_id
                    and id = ($1->>'mobilization_id')::integer
                into _mobilization;
            
            select * from public.activists a
                where a.email = lower(($1->>'email')::email)
                limit 1 into _activist;
                
            if _activist.id is null then 
                insert into public.activists (name, email, phone, document_number, document_type, city, created_at, updated_at)
                    values ($1->>'name'::text, lower($1->>'email'), $1->>'phone'::text, $1->>'document_number'::text,
                        $1->>'document_type'::text, $1->>'city'::text, now(), now())
                    returning * into _activist;
            end if;
            
            if not exists(select true 
                from public.community_activists 
                where community_id = _community_id 
                    and activist_id = _activist.id
            ) then
                insert into public.community_activists (community_id, activist_id, created_at, updated_at)
                    values (_community_id, _activist.id, now(), now());
            end if;
            
            if _mobilization.id is not null and not exists(select true 
                from public.mobilization_activists 
                where mobilization_id = _mobilization.id
                    and activist_id = _activist.id
            ) then
                insert into public.mobilization_activists (mobilization_id, activist_id, created_at, updated_at)
                    values (_mobilization.id, _activist.id, now(), now());
            end if;            

            return row_to_json(_activist);
        end;
    $function$

}
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION postgraphql.create_activist(activist json)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
        declare
            _activist public.activists;
            _community_id integer;
            _mobilization public.mobilizations;
        begin
            _community_id := ($1->>'community_id')::integer;

            if not postgraphql.current_user_has_community_participation(_community_id) then
                raise 'operation not permitted';
            end if;

            if _community_id is null then
                raise 'missing community_id inside activist';
            end if;

            select * from public.mobilizations
                where community_id = _community_id
                    and id = ($1->>'mobilization_id')::integer
                into _mobilization;

            insert into public.activists (name, email, phone, document_number, document_type, city, created_at, updated_at)
                values ($2->>'name'::text, $2->>'email', $2->>'phone'::text, $2->>'document_number'::text,
                    $2->>'document_type'::text, $2->>'city'::text, now(), now())
                returning * into _activist;

            insert into public.community_activists (community_id, activist_id, created_at, updated_at)
                values ($1, _activist.id, now(), now());

            return row_to_json(_activist);
        end;
    $function$
;
}
  end
end
