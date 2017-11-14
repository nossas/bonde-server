class AddFacebookBotCampaignActivistsActionsToPostgraphql < ActiveRecord::Migration
  def up
    execute %Q{
CREATE TYPE postgraphql.get_facebook_bot_campaign_activists_by_campaign_type AS (
    id integer,
    facebook_bot_campaign_id integer,
    facebook_bot_activist_id integer,
    received boolean,
    "log" jsonb,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    fb_context_recipient_id text,
    fb_context_sender_id text,
    data jsonb,
    messages tsvector,
    quick_replies text[],
    interaction_dates timestamp without time zone[]
);

CREATE OR REPLACE FUNCTION postgraphql.get_facebook_bot_campaign_activists_by_campaign_id (
    campaign_id INTEGER
)
    RETURNS SETOF postgraphql.get_facebook_bot_campaign_activists_by_campaign_type
    LANGUAGE sql
    IMMUTABLE
AS $function$
    SELECT
        fbca.*,
        fba.fb_context_recipient_id,
        fba.fb_context_sender_id,
        fba.data,
        fba.messages,
        fba.quick_replies,
        fba.interaction_dates
    FROM public.facebook_bot_campaign_activists as fbca
    LEFT JOIN public.facebook_bot_activists as fba
        ON fba.id = fbca.facebook_bot_activist_id
    WHERE fbca.facebook_bot_campaign_id = campaign_id;
$function$;

CREATE OR REPLACE FUNCTION postgraphql.update_facebook_bot_campaign_activists(
    facebook_bot_campaign_activist_id integer,
    ctx_received boolean,
    ctx_log jsonb
)
    RETURNS public.facebook_bot_campaign_activists
    LANGUAGE plpgsql
AS $function$
    DECLARE
        v_facebook_bot_campaign_activist public.facebook_bot_campaign_activists;
    BEGIN
        UPDATE public.facebook_bot_campaign_activists SET
            received = ctx_received,
            "log" = ctx_log,
            updated_at = NOW()
        WHERE id = facebook_bot_campaign_activist_id
        RETURNING * INTO v_facebook_bot_campaign_activist;
        RETURN v_facebook_bot_campaign_activist;
    END;
$function$;
}
  end

  def down
    execute %Q{
DROP FUNCTION postgraphql.update_facebook_bot_campaign_activists(
    facebook_bot_campaign_activist_id integer,
    ctx_received boolean,
    ctx_log jsonb
);
DROP FUNCTION postgraphql.get_facebook_bot_campaign_activists_by_campaign_id (
    campaign_id INTEGER
);
DROP TYPE postgraphql.get_facebook_bot_campaign_activists_by_campaign_type;
}
  end
end
