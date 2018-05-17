-- helper id functions
create or replace function __demo_community_id()
returns integer language sql as $$ select 99999 $$;

create or replace function __demo_mobilization_id()
returns integer language sql as $$ select 99999 $$;

create or replace function __demo_block_id()
returns integer language sql as $$ select 99999 $$;

create or replace function __demo_widget_id()
returns integer language sql as $$ select 99999 $$;

create or replace function __demo_community_activist_id()
returns integer language sql as $$ select 99999 $$;

create or replace function __demo_activist_id()
returns integer language sql as $$ select 99999 $$;


-- insert demo community
insert into public.communities (id, name, created_at, updated_at)
    values (__demo_community_id(), 'demo_com', now(), now());

insert into mobilizations (id, created_at, updated_at, name, community_id, slug)
    values (__demo_mobilization_id(), now(), now(), 'mob_demo', __demo_community_id(), 'mob_slug');

insert into blocks (id, name, created_at, updated_at, mobilization_id)
    values (__demo_block_id(), 'demo_block', now(), now(), __demo_mobilization_id());

insert into widgets (id, block_id, created_at, updated_at)
    values (__demo_widget_id(), __demo_block_id(), now(), now());

insert into activists(id, name, email, first_name, last_name, created_at, updated_at)
  values (__demo_activist_id(), 'test full name', 'test@email.com', 'test', 'full_name', now(), now());

insert into community_activists(id, community_id, activist_id, profile_data, created_at, updated_at)
values (__demo_community_activist_id(), __demo_community_id(), __demo_activist_id(), json_build_object(
  'id', __demo_activist_id(),
  'name', 'test full name',
  'email', 'test@email.com',
  'first_name', 'test',
  'last_name', 'full name',
  'created_at', now(),
  'updated_at', now()
)::jsonb, now(), now());
