class AddFacebookBotInteractionsToGraphql < ActiveRecord::Migration
  def up
    execute %Q{
grant select, insert, update, delete on public.activist_facebook_bot_interactions to admin;
grant usage on sequence public.activist_facebook_bot_interactions_id_seq to admin;

create or replace function postgraphql.create_bot_interaction(bot_data json)
    returns json LANGUAGE plpgsql AS $$
        declare
            bot_json public.activist_facebook_bot_interactions;
        begin
            insert into public.activist_facebook_bot_interactions
                (facebook_bot_configuration_id, fb_context_recipient_id, fb_context_sender_id, interaction, created_at, updated_at)
                values (
                    (bot_data ->> 'facebook_bot_configuration_id')::integer,
                    (bot_data ->> 'fb_context_recipient_id'),
                    (bot_data ->> 'fb_context_sender_id'),
                    coalesce((bot_data ->> 'interaction')::jsonb, '{}'),
                    now(),
                    now())
                returning * into bot_json;

                return row_to_json(bot_json);
        end;
    $$;
}
  end

  def down
    execute %Q{
drop function postgraphql.create_bot_interaction(bot_data json);
}
  end
end
