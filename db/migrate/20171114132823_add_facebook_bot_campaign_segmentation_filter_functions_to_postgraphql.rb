class AddFacebookBotCampaignSegmentationFilterFunctionsToPostgraphql < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION postgraphql.get_facebook_activists_by_campaigns_exclusion(
    segment_filters jsonb,
    campaign_ids int[]
)
    RETURNS SETOF postgraphql.facebook_activist_search_result_type
    LANGUAGE sql
    IMMUTABLE
AS $function$
    SELECT
        fas.fb_context_recipient_id,
        fas.fb_context_sender_id,
        fas.data,
        fas.messages,
        fas.quick_replies,
        fas.created_at,
        fas.updated_at,
        fas.id
    FROM postgraphql.get_facebook_activists_strategy(segment_filters) as fas
    LEFT JOIN (
        SELECT fba.*
        FROM public.facebook_bot_campaign_activists as fbca
        LEFT JOIN public.facebook_bot_activists as fba
            ON fba.id = fbca.facebook_bot_activist_id
        WHERE fbca.facebook_bot_campaign_id = ANY(campaign_ids)
    ) as fbca
        ON fbca.fb_context_recipient_id = fas.fb_context_recipient_id
    WHERE fbca.id IS NULL
    ORDER BY fas.updated_at DESC;
$function$;

CREATE OR REPLACE FUNCTION postgraphql.get_facebook_activists_by_campaign_ids(
    campaign_ids int[]
)
    RETURNS SETOF postgraphql.facebook_activist_search_result_type
    LANGUAGE sql
    IMMUTABLE
AS $function$
    SELECT
        DISTINCT _fba.fb_context_recipient_id,
        _fba.fb_context_sender_id,
        _fba.data,
        _fba.messages,
        _fba.quick_replies,
        _fba.created_at,
        _fba.updated_at,
        _fba.id
    FROM public.facebook_bot_campaign_activists as _fbca
    LEFT JOIN public.facebook_bot_activists as _fba
        ON _fba.id = _fbca.facebook_bot_activist_id
    WHERE _fbca.facebook_bot_campaign_id = ANY(campaign_ids)
$function$;

CREATE OR REPLACE FUNCTION postgraphql.get_facebook_activists_by_campaigns_inclusion(
    segment_filters jsonb,
    campaign_ids int[]
)
    RETURNS SETOF postgraphql.facebook_activist_search_result_type
    LANGUAGE sql
    IMMUTABLE
AS $function$
    SELECT
        fas.fb_context_recipient_id,
        fas.fb_context_sender_id,
        fas.data,
        fas.messages,
        fas.quick_replies,
        fas.created_at,
        fas.updated_at,
        fas.id
    FROM postgraphql.get_facebook_activists_strategy(segment_filters) as fas
    UNION
    SELECT *
    FROM postgraphql.get_facebook_activists_by_campaign_ids(campaign_ids);
$function$;

CREATE OR REPLACE FUNCTION postgraphql.get_facebook_activists_by_campaigns_both_inclusion_exclusion(
    segment_filters jsonb,
    campaign_exclusion_ids int[],
    campaign_inclusion_ids int[]
)
    RETURNS SETOF postgraphql.facebook_activist_search_result_type
    LANGUAGE sql
    IMMUTABLE
AS $function$
    SELECT *
    FROM postgraphql.get_facebook_activists_by_campaigns_exclusion(
        segment_filters,
        campaign_exclusion_ids
    )
    UNION
    SELECT *
    FROM postgraphql.get_facebook_activists_by_campaign_ids(
        campaign_inclusion_ids
    );
$function$;

CREATE OR REPLACE FUNCTION postgraphql.get_facebook_activists_strategy(search jsonb)
RETURNS setof postgraphql.facebook_activist_search_result_type
LANGUAGE plpgsql
IMMUTABLE
AS $function$
    DECLARE
        _message                text      := search ->> 'message';
        _quick_reply            text      := search ->> 'quickReply';
        _date_interval_start    timestamp := search ->> 'dateIntervalStart';
        _date_interval_end      timestamp := search ->> 'dateIntervalEnd';
        _campaign_exclusion_ids int[]     := search ->> 'campaignExclusionIds';
        _campaign_inclusion_ids int[]     := search ->> 'campaignInclusionIds';

        _m      boolean := _message                IS NOT NULL;
        _qr     boolean := _quick_reply            IS NOT NULL;
        _start  boolean := _date_interval_start    IS NOT NULL;
        _end    boolean := _date_interval_end      IS NOT NULL;
        _ce     boolean := _campaign_exclusion_ids IS NOT NULL;
        _ci     boolean := _campaign_inclusion_ids IS NOT NULL;

        _is_only_campaign_exclusion boolean :=      _ce  AND (NOT _ci);
        _is_only_campaign_inclusion boolean := (NOT _ce) AND      _ci;
        _is_both_campaign_strategy  boolean :=      _ce  AND      _ci;
        _is_only_message            boolean :=      _m  AND (NOT _qr) AND (NOT _start) AND (NOT _end);
        _is_only_q_reply            boolean := (NOT _m) AND      _qr  AND (NOT _start) AND (NOT _end);
        _is_only_date_interval      boolean := (NOT _m) AND (NOT _qr) AND      _start  AND      _end;
        _is_q_reply_date_interval   boolean := (NOT _m) AND      _qr  AND       _start AND      _end;
        _is_message_date_interval   boolean :=      _m  AND (NOT _qr) AND      _start  AND      _end;
        _is_message_q_reply         boolean :=      _m  AND      _qr  AND (NOT _start) AND (NOT _end);
        _is_all                     boolean :=      _m  AND      _qr  AND      _start  AND      _end;
    BEGIN
        IF _is_only_campaign_exclusion THEN RETURN QUERY (
            SELECT *
            FROM postgraphql.get_facebook_activists_by_campaigns_exclusion(
                search - 'campaignExclusionIds',
                _campaign_exclusion_ids
            )
        );
        ELSIF _is_only_campaign_inclusion THEN RETURN QUERY (
            SELECT *
            FROM postgraphql.get_facebook_activists_by_campaigns_inclusion(
                search - 'campaignInclusionIds',
                _campaign_inclusion_ids
            )
        );
        ELSIF _is_both_campaign_strategy THEN RETURN QUERY (
            SELECT *
            FROM postgraphql.get_facebook_activists_by_campaigns_both_inclusion_exclusion(
                search - 'campaignInclusionIds' - 'campaignExclusionIds',
                _campaign_exclusion_ids,
                _campaign_inclusion_ids
            )
        );
        ELSE
            IF _is_only_message THEN RETURN QUERY (
                SELECT *
                FROM postgraphql.get_facebook_activists_by_message(_message)
            );
            ELSIF _is_only_q_reply THEN RETURN QUERY (
                SELECT *
                FROM postgraphql.get_facebook_activists_by_quick_reply(_quick_reply)
            );
            ELSIF _is_only_date_interval THEN RETURN QUERY (
                SELECT *
                FROM postgraphql.get_facebook_activists_by_date_interval(
                    _date_interval_start,
                    _date_interval_end
                )
            );
            ELSIF _is_q_reply_date_interval THEN RETURN QUERY (
                SELECT *
                FROM postgraphql.get_facebook_activists_by_quick_reply_date_interval(
                    _quick_reply,
                    _date_interval_start,
                    _date_interval_end
                )
            );
            ELSIF _is_message_date_interval THEN RETURN QUERY (
                SELECT *
                FROM postgraphql.get_facebook_activists_by_message_date_interval(
                    _message,
                    _date_interval_start,
                    _date_interval_end
                )
            );
            ELSIF _is_message_q_reply THEN RETURN QUERY (
                SELECT *
                FROM postgraphql.get_facebook_activists_by_message_quick_reply(
                    _message,
                    _quick_reply
                )
            );
            ELSIF _is_all THEN RETURN QUERY (
                SELECT *
                FROM postgraphql.get_facebook_activists_by_message_quick_reply_date_interval(
                    _message,
                    _quick_reply,
                    _date_interval_start,
                    _date_interval_end
                )
            );
            END IF;
        END IF;
    END;
$function$;
}
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION postgraphql.get_facebook_activists_strategy(search jsonb)
RETURNS setof postgraphql.facebook_activist_search_result_type
LANGUAGE plpgsql
IMMUTABLE
AS $function$
    DECLARE
        _message text := search ->> 'message';
        _quickReply text := search ->> 'quickReply';
        _dateIntervalStart timestamp := search ->> 'dateIntervalStart';
        _dateIntervalEnd timestamp := search ->> 'dateIntervalEnd';
        _m boolean := _message IS NOT NULL;
        _qr boolean := _quickReply IS NOT NULL;
        _start boolean := _dateIntervalStart IS NOT NULL;
        _end boolean := _dateIntervalEnd IS NOT NULL;
        _is_only_message boolean :=               _m  AND (NOT _qr) AND (NOT _start) AND (NOT _end);
        _is_only_q_reply boolean :=          (NOT _m) AND      _qr  AND (NOT _start) AND (NOT _end);
        _is_only_date_interval boolean :=    (NOT _m) AND (NOT _qr) AND      _start  AND      _end;
        _is_q_reply_date_interval boolean := (NOT _m) AND      _qr  AND       _start AND      _end;
        _is_message_date_interval boolean :=      _m  AND (NOT _qr) AND      _start  AND      _end;
        _is_message_q_reply boolean :=            _m  AND      _qr  AND (NOT _start) AND (NOT _end);
        _is_all boolean :=                        _m  AND      _qr  AND      _start  AND      _end;
    BEGIN
        IF _is_only_message THEN RETURN QUERY (
            SELECT * FROM postgraphql.get_facebook_activists_by_message(_message)
        );
        ELSIF _is_only_q_reply THEN RETURN QUERY (
            SELECT * FROM postgraphql.get_facebook_activists_by_quick_reply(_quickReply)
        );
        ELSIF _is_only_date_interval THEN RETURN QUERY (
            SELECT * FROM postgraphql.get_facebook_activists_by_date_interval(
                _dateIntervalStart,
                _dateIntervalEnd
            )
        );
        ELSIF _is_q_reply_date_interval THEN RETURN QUERY (
            SELECT * FROM postgraphql.get_facebook_activists_by_quick_reply_date_interval(
                _quickReply,
                _dateIntervalStart,
                _dateIntervalEnd
            )
        );
        ELSIF _is_message_date_interval THEN RETURN QUERY (
            SELECT * FROM postgraphql.get_facebook_activists_by_message_date_interval(
                _message,
                _dateIntervalStart,
                _dateIntervalEnd
            )
        );
        ELSIF _is_message_q_reply THEN RETURN QUERY (
            SELECT * FROM postgraphql.get_facebook_activists_by_message_quick_reply(
                _message,
                _quickReply
            )
        );
        ELSIF _is_all THEN RETURN QUERY (
            SELECT * FROM postgraphql.get_facebook_activists_by_message_quick_reply_date_interval(
                _message,
                _quickReply,
                _dateIntervalStart,
                _dateIntervalEnd
            )
        );
        END IF;
    END;
$function$;

DROP FUNCTION postgraphql.get_facebook_activists_by_campaigns_both_inclusion_exclusion(
    segment_filters jsonb,
    campaign_exclusion_ids int[],
    campaign_inclusion_ids int[]
);
DROP FUNCTION postgraphql.get_facebook_activists_by_campaigns_inclusion(
    segment_filters jsonb,
    campaign_ids int[]
);
DROP FUNCTION postgraphql.get_facebook_activists_by_campaign_ids(
  campaign_ids int[]
);
DROP FUNCTION postgraphql.get_facebook_activists_by_campaigns_exclusion(
    segment_filters jsonb,
    campaign_ids int[]
);
}
  end
end
