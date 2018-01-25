-- helper id functions
create or replace function __demo_community_id()
returns integer language sql as $$ select 99999 $$;

create or replace function __demo_mobilization_id()
returns integer language sql as $$ select 99999 $$;

create or replace function __demo_block_id()
returns integer language sql as $$ select 99999 $$;

create or replace function __demo_widget_id()
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
