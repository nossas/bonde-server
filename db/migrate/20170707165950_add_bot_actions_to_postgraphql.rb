class AddBotActionsToPostgraphql < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function postgraphql.create_bot(bot_data json)
    returns json LANGUAGE plpgsql AS $$
        declare
            bot_json public.facebook_bot_configurations;
        begin
            insert into public.facebook_bot_configurations
                (community_id, messenger_app_secret, messenger_validation_token, messenger_page_access_token, data, created_at, updated_at)
                values (
                    (bot_data ->> 'community_id')::integer,
                    (bot_data ->> 'messenger_app_secret'),
                    (bot_data ->> 'messenger_validation_token'),
                    (bot_data ->> 'messenger_page_access_token'),
                    coalesce((bot_data ->> 'data')::jsonb, '{}'),
                    now(),
                    now())
                returning * into bot_json;

                return row_to_json(bot_json);
        end;
    $$;


grant select, insert, update, delete on public.facebook_bot_configurations to admin;
grant usage on sequence public.facebook_bot_configurations_id_seq to admin;

create or replace view postgraphql.facebook_bot_configurations as
    select
        *
    from public.facebook_bot_configurations
      where (data ->> 'deleted') is null;

grant select on postgraphql.facebook_bot_configurations to admin;

create or replace function postgraphql.destroy_bot(bot_id integer) returns void 
    language sql as $$
        update public.facebook_bot_configurations
            set data = jsonb_set(data, '{deleted}', 'true')
        where id = bot_id
    $$;

create or replace function postgraphql.update_bot(bot_data json)
    returns json LANGUAGE plpgsql AS $$
        declare
            bot_json public.facebook_bot_configurations;
        begin
            update public.facebook_bot_configurations
                set community_id = coalesce((bot_data ->> 'community_id')::integer, community_id)::integer, 
                    messenger_app_secret = coalesce((bot_data ->> 'messenger_app_secret'), messenger_app_secret), 
                    messenger_validation_token = coalesce((bot_data ->> 'messenger_validation_token'), messenger_validation_token),
                    messenger_page_access_token = coalesce((bot_data ->> 'messenger_page_access_token'), messenger_validation_token), 
                    data = coalesce((bot_data ->> 'data')::jsonb, data), 
                    updated_at = now()
                where id = (bot_data ->> 'id')::integer
                returning * into bot_json;

                return row_to_json(bot_json);
        end;
    $$;
}
  end

  def down
    execute %Q{
drop function postgraphql.create_bot(bot_data json);
drop function postgraphql.destroy_bot(bot_id integer);
drop function postgraphql.update_bot(bot_data json);
drop view postgraphql.facebook_bot_configurations;
}
  end
end
