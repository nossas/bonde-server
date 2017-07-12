class AddFacebookBotInteractionsView < ActiveRecord::Migration
  def up
    execute %Q{
create or replace view postgraphql.activist_facebook_bot_interactions as
    select
        i.*,
        c.community_id,
        c.data as facebook_bot_configuration
    from activist_facebook_bot_interactions as i
      join facebook_bot_configurations as c
        on i.facebook_bot_configuration_id = c.id
    where postgraphql.current_user_has_community_participation(c.community_id);


CREATE OR REPLACE FUNCTION postgraphql.current_user_has_community_participation(com_id integer)
 RETURNS boolean
 LANGUAGE sql
AS $function$
        select (exists(
            select true from public.community_users cu
                where cu.user_id = postgraphql.current_user_id()
                and cu.community_id = com_id
        ) or current_role = 'admin');
    $function$;

create or replace view postgraphql.bot_recipients as
    select
        i.facebook_bot_configuration_id, 
        i.fb_context_recipient_id, 
        i.fb_context_sender_id,
        i.interaction,
        c.community_id,
        c.data as facebook_bot_configuration,
        i.created_at
    from activist_facebook_bot_interactions as i
      left join activist_facebook_bot_interactions as aux
        on (
          i.facebook_bot_configuration_id = aux.facebook_bot_configuration_id and
          i.fb_context_recipient_id = aux.fb_context_recipient_id and
          i.fb_context_sender_id = aux.fb_context_sender_id and
          i.id < aux.id
        )
      left join facebook_bot_configurations as c
        on i.facebook_bot_configuration_id = c.id
    where aux.id is null and postgraphql.current_user_has_community_participation(c.community_id);

grant select on postgraphql.bot_recipients to admin;
}
  end

  def down
    execute %Q{
    drop view if exists postgraphql.activist_facebook_bot_interactions;
    drop view if exists postgraphql.bot_recipients;
    CREATE OR REPLACE FUNCTION postgraphql.current_user_has_community_participation(com_id integer)
 RETURNS boolean
 LANGUAGE sql
AS $function$
        select exists(
            select true from public.community_users cu
                where cu.user_id = postgraphql.current_user_id()
                and cu.community_id = com_id
        );
    $function$;
}
  end
end
