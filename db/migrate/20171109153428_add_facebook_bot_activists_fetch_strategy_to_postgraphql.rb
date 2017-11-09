class AddFacebookBotActivistsFetchStrategyToPostgraphql < ActiveRecord::Migration
  def up
    execute %Q{
ALTER TYPE postgraphql.facebook_activist_search_result_type ADD ATTRIBUTE id integer;

CREATE OR REPLACE FUNCTION postgraphql.get_facebook_activists_by_date_interval(
    date_interval_start timestamp,
    date_interval_end timestamp
)
    RETURNS setof postgraphql.facebook_activist_search_result_type
    LANGUAGE sql
    IMMUTABLE
AS $function$
    SELECT DISTINCT
        fb_context_recipient_id,
        fb_context_sender_id,
        data,
        messages,
        quick_replies,
        created_at,
        updated_at,
        id
    FROM (
        SELECT *, UNNEST(interaction_dates) as interaction_date
        FROM public.facebook_bot_activists
    ) as a
    WHERE interaction_date::date BETWEEN date_interval_start AND date_interval_end
    ORDER BY updated_at;
$function$;

CREATE OR REPLACE FUNCTION postgraphql.get_facebook_activists_by_quick_reply(quick_reply text)
    RETURNS setof postgraphql.facebook_activist_search_result_type
    LANGUAGE sql
    IMMUTABLE
AS $function$
    SELECT
        fb_context_recipient_id,
        fb_context_sender_id,
        data,
        messages,
        quick_replies,
        created_at,
        updated_at,
        id
    FROM public.facebook_bot_activists
    WHERE quick_reply = ANY(quick_replies)
    ORDER BY updated_at DESC;
$function$;

CREATE OR REPLACE FUNCTION postgraphql.get_facebook_activists_by_message_quick_reply(
    message text,
    quick_reply text
)
    RETURNS setof postgraphql.facebook_activist_search_result_type
    LANGUAGE sql
    IMMUTABLE
AS $function$
    SELECT
        fb_context_recipient_id,
        fb_context_sender_id,
        data,
        messages,
        quick_replies,
        created_at,
        updated_at,
        id
    FROM public.facebook_bot_activists
    WHERE
        messages @@ plainto_tsquery('portuguese', message) AND
        quick_reply = ANY(quick_replies)
    ORDER BY updated_at DESC;
$function$;

CREATE OR REPLACE FUNCTION postgraphql.get_facebook_activists_by_message(message text)
    RETURNS setof postgraphql.facebook_activist_search_result_type
    LANGUAGE sql
    IMMUTABLE
AS $function$
    SELECT
        fb_context_recipient_id,
        fb_context_sender_id,
        data,
        messages,
        quick_replies,
        created_at,
        updated_at,
        id
    FROM public.facebook_bot_activists
    WHERE messages @@ plainto_tsquery('portuguese', message)
    ORDER BY updated_at DESC;
$function$;

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
}
  end

  def down
    execute %Q{
DROP FUNCTION postgraphql.get_facebook_activists_strategy(data jsonb);

ALTER TYPE postgraphql.facebook_activist_search_result_type DROP ATTRIBUTE IF EXISTS id;

CREATE OR REPLACE FUNCTION postgraphql.get_facebook_activists_by_message(message text)
    RETURNS setof postgraphql.facebook_activist_search_result_type
    LANGUAGE sql
    IMMUTABLE
AS $function$
    SELECT
        fb_context_recipient_id,
        fb_context_sender_id,
        data,
        messages,
        quick_replies,
        created_at,
        updated_at
    FROM public.facebook_bot_activists
    WHERE messages @@ plainto_tsquery('portuguese', message)
    ORDER BY updated_at DESC;
$function$;

CREATE OR REPLACE FUNCTION postgraphql.get_facebook_activists_by_message_quick_reply(
    message text,
    quick_reply text
)
    RETURNS setof postgraphql.facebook_activist_search_result_type
    LANGUAGE sql
    IMMUTABLE
AS $function$
    SELECT
        fb_context_recipient_id,
        fb_context_sender_id,
        data,
        messages,
        quick_replies,
        created_at,
        updated_at
    FROM public.facebook_bot_activists
    WHERE
        messages @@ plainto_tsquery('portuguese', message) AND
        quick_reply = ANY(quick_replies)
    ORDER BY updated_at DESC;
$function$;

CREATE OR REPLACE FUNCTION postgraphql.get_facebook_activists_by_quick_reply(quick_reply text)
    RETURNS setof postgraphql.facebook_activist_search_result_type
    LANGUAGE sql
    IMMUTABLE
AS $function$
    SELECT
        fb_context_recipient_id,
        fb_context_sender_id,
        data,
        messages,
        quick_replies,
        created_at,
        updated_at
    FROM public.facebook_bot_activists
    WHERE quick_reply = ANY(quick_replies)
    ORDER BY updated_at DESC;
$function$;

CREATE OR REPLACE FUNCTION postgraphql.get_facebook_activists_by_date_interval(
    date_interval_start timestamp,
    date_interval_end timestamp
)
    RETURNS setof postgraphql.facebook_activist_search_result_type
    LANGUAGE sql
    IMMUTABLE
AS $function$
    SELECT DISTINCT
        fb_context_recipient_id,
        fb_context_sender_id,
        data,
        messages,
        quick_replies,
        created_at,
        updated_at
    FROM (
        SELECT *, UNNEST(interaction_dates) as interaction_date
        FROM public.facebook_bot_activists
    ) as a
    WHERE interaction_date::date BETWEEN date_interval_start AND date_interval_end
    ORDER BY updated_at;
$function$;
}
  end
end
