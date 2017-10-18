class AddCreateActivistIntoPostgraphql < ActiveRecord::Migration
  def up
    execute %Q{
CREATE EXTENSION if not exists citext;
CREATE DOMAIN email AS citext
    CHECK ( value ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$' );

update activists
    set email = lower(unaccent(btrim(email)));

CREATE OR REPLACE VIEW "public"."first_email_ids_activists" AS 
 SELECT min(activists.id) AS min_id,
    lower((activists.email)::text) AS email,
    array_agg(activists.id) as ids
   FROM activists
  GROUP BY activists.email;

update activist_pressures resource
    set activist_id = af.min_id
    from first_email_ids_activists af
        where resource.activist_id <> af.min_id
            and resource.activist_id = ANY(af.ids);

update form_entries resource
    set activist_id = af.min_id
    from first_email_ids_activists af
        where resource.activist_id <> af.min_id
            and resource.activist_id = ANY(af.ids);

update donations resource
    set activist_id = af.min_id
    from first_email_ids_activists af
        where resource.activist_id <> af.min_id
            and resource.activist_id = ANY(af.ids);

update subscriptions resource
    set activist_id = af.min_id
    from first_email_ids_activists af
        where resource.activist_id <> af.min_id
            and resource.activist_id = ANY(af.ids);

update activist_tags resource
    set activist_id = af.min_id
    from first_email_ids_activists af
        where resource.activist_id <> af.min_id
            and resource.activist_id = ANY(af.ids);

update notifications resource
    set activist_id = af.min_id
    from first_email_ids_activists af
        where resource.activist_id <> af.min_id
            and resource.activist_id = ANY(af.ids);

delete from addresses where not exists (select true from first_email_ids_activists where min_id = activist_id);
delete from activist_pressures where not exists (select true from first_email_ids_activists where min_id = activist_id);
delete from mobilization_activists where not exists (select true from first_email_ids_activists where min_id = activist_id);
delete from community_activists where not exists (select true from first_email_ids_activists where min_id = activist_id);
delete from form_entries where not exists (select true from first_email_ids_activists where min_id = activist_id);
delete from activist_tags where not exists (select true from first_email_ids_activists where min_id = activist_id);
delete from activists where not exists (select true from first_email_ids_activists where min_id = id);

delete from mobilization_activists ma where ma.id in (
    select m2.id from mobilization_activists m2
    join activists a on a.id = m2.activist_id
    where not unaccent(lower(btrim(a.email))) ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
);

delete from community_activists ma where ma.id in (
    select m2.id from community_activists m2
    join activists a on a.id = m2.activist_id
    where not unaccent(lower(btrim(a.email))) ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
);

delete from form_entries ma where ma.id in (
    select m2.id from form_entries m2
    join activists a on a.id = m2.activist_id
    where not unaccent(lower(btrim(a.email))) ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
);

delete from activist_pressures ma where ma.id in (
    select m2.id from activist_pressures m2
    join activists a on a.id = m2.activist_id
    where not unaccent(lower(btrim(a.email))) ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
);

delete from activist_tags ma where ma.id in (
    select m2.id from activist_tags m2
    join activists a on a.id = m2.activist_id
    where not unaccent(lower(btrim(a.email))) ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
);

delete from activists where not email ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$';


create unique index uniq_email_acts on activists(lower(email::email));

create or replace function postgraphql.create_activist(activist json)
    returns json
    language plpgsql
    volatile
    as $$
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
    $$;
}
  end

  def down
    execute %Q{
drop unique index uniq_email_acts on activists(lower(email::email));

CREATE OR REPLACE VIEW "public"."first_email_ids_activists" AS 
 SELECT min(activists.id) AS min_id,
    lower((activists.email)::text) AS email,
    array_agg(activists.id) as ids
   FROM activists
  GROUP BY activists.email;
drop function postgraphql.create_activist(activist json);
drop domain email;
}
  end
end
