class AddFacebookBotCampaignActionsToPostgraphql < ActiveRecord::Migration
  def up
    execute %Q{
GRANT SELECT, INSERT, UPDATE, DELETE ON public.facebook_bot_campaigns TO admin, common_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.facebook_bot_campaign_activists TO admin, common_user;
GRANT USAGE ON SEQUENCE public.facebook_bot_campaigns_id_seq TO admin, common_user;
GRANT USAGE ON SEQUENCE public.facebook_bot_campaign_activists_id_seq TO admin, common_user;

CREATE TYPE postgraphql.facebook_bot_campaigns_type AS (
  facebook_bot_configuration_id integer,
  name text,
  segment_filters jsonb,
  total_impacted_activists integer
);

CREATE OR REPLACE FUNCTION postgraphql.create_facebook_bot_campaign(
    campaign postgraphql.facebook_bot_campaigns_type
)
RETURNS public.facebook_bot_campaigns
LANGUAGE plpgsql AS $function$
    DECLARE
        _facebook_bot_campaign public.facebook_bot_campaigns;
        _campaign_id integer;
    BEGIN
        INSERT INTO public.facebook_bot_campaigns (
            facebook_bot_configuration_id,
            name,
            segment_filters,
            total_impacted_activists,
            created_at,
            updated_at
        ) VALUES (
            campaign.facebook_bot_configuration_id,
            campaign.name,
            campaign.segment_filters,
            campaign.total_impacted_activists,
            now(),
            now()
        ) RETURNING * INTO _facebook_bot_campaign;

        INSERT INTO public.facebook_bot_campaign_activists (
            facebook_bot_campaign_id,
            facebook_bot_activist_id,
            received,
            created_at,
            updated_at
        )
            SELECT
                (to_json(_facebook_bot_campaign) ->> 'id')::integer as facebook_bot_activist_id,
                id as facebook_bot_activist_id,
                FALSE,
                NOW(),
                NOW()
            FROM postgraphql.get_facebook_activists_strategy(campaign.segment_filters);
      RETURN _facebook_bot_campaign;
    END;
$function$;

CREATE OR REPLACE FUNCTION postgraphql.get_facebook_bot_campaigns_by_community_id(
    ctx_community_id integer
)
    RETURNS setof public.facebook_bot_campaigns
    LANGUAGE sql
    IMMUTABLE
AS $function$
    SELECT campaigns.*
    FROM public.facebook_bot_campaigns as campaigns
    LEFT JOIN public.facebook_bot_configurations as configs
        ON campaigns.facebook_bot_configuration_id = configs.id
    WHERE configs.community_id = ctx_community_id;
$function$;
}
  end

  def down
    %Q{
DROP FUNCTION postgraphql.get_facebook_bot_campaigns_by_community_id(ctx_community_id integer);
DROP FUNCTION postgraphql.create_facebook_bot_campaign(campaign postgraphql.facebook_bot_campaigns_type);
DROP TYPE postgraphql.facebook_bot_campaigns_type;
REVOKE USAGE ON SEQUENCE public.facebook_bot_campaign_activists_id_seq FROM admin, common_user;
REVOKE USAGE ON SEQUENCE public.facebook_bot_campaigns_id_seq FROM admin, common_user;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.facebook_bot_campaign_activists FROM admin, common_user;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.facebook_bot_campaigns FROM admin, common_user;
}
  end
end
