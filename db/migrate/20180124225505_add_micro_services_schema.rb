class AddMicroServicesSchema < ActiveRecord::Migration
  def change
    execute %Q{
      create schema microservices;

      do $$
      begin
        if not exists(select 1 from pg_roles where rolname = 'microservices') then
          create role microservices;
        end if;
      end;
      $$;

      create type microservices.jwt_token as (
        role text,
        user_id integer
      );
      grant usage on schema microservices to microservices;
      grant usage on schema public to microservices;
      grant select on public.users to microservices;

      create or replace function microservices.current_user() returns public.users as $$
        select
          *
        from
          public.users
        where
          id = current_setting('jwt.claims.user_id')::integer
      $$ language sql stable;
      comment on function microservices.current_user() is 'Gets the user who was indentified by our JWT.';
      grant select on public.users to microservices;

      create or replace function microservices.current_user_id() returns integer
      language sql as $$
          select id from microservices.current_user();
      $$;

      create or replace view microservices.communities as
      select
          distinct c.*
      from public.communities c
          right join public.mobilizations m on c.id = m.community_id
      WHERE
          m.custom_domain is not null and microservices.current_user_id() is not null;
      grant select on microservices.communities to microservices;

      create or replace view microservices.mobilizations as
          select
              *
          from
            public.mobilizations
          where
            custom_domain is not null and microservices.current_user_id() is not null;
      grant select on microservices.mobilizations to microservices;

      create or replace view microservices.dns_hosted_zones as
          select
              *
          from
            public.dns_hosted_zones
          where
            ns_ok is true and microservices.current_user_id() is not null;
      grant select on microservices.dns_hosted_zones to microservices;

      create or replace view microservices.certificates as
        select
          *
        from
          public.certificates
        where
          is_active is true and microservices.current_user_id() is not null;
      grant select on microservices.certificates to microservices;
    }
  end
  def down
    execute %Q{
      revoke select, insert on public.certificates from microservices;
      drop view microservices.dns_hosted_zones;
      drop view microservices.mobilizations;
      drop view microservices.communities;
      drop function microservices.current_user();
      revoke usage on schema microservices from microservices;

      DROP role microservices;
      DROP type microservices.jwt_token;
      DROP schema microservices;
    }
  end

end
