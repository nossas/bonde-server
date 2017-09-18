class AddFacebookBotActivistsSearchActionsToPostgraphql < ActiveRecord::Migration
  def up
    execute %Q{
CREATE TYPE postgraphql.facebook_activist_search_result_type AS (
    fb_context_recipient_id text,
    fb_context_sender_id text,
    data jsonb,
    messages tsvector,
    quick_replies text[],
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

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

CREATE OR REPLACE FUNCTION postgraphql.get_facebook_activists_by_quick_reply_date_interval(
    quick_reply text,
    date_interval_start timestamp,
    date_interval_end timestamp
)
    RETURNS setof postgraphql.facebook_activist_search_result_type
    LANGUAGE sql
    IMMUTABLE
AS $function$
    SELECT *
    FROM postgraphql.get_facebook_activists_by_date_interval(
        date_interval_start,
        date_interval_end
    )
    WHERE quick_reply = ANY(quick_replies)
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
        updated_at
    FROM public.facebook_bot_activists
    WHERE messages @@ plainto_tsquery('portuguese', message)
    ORDER BY updated_at DESC;
$function$;

CREATE OR REPLACE FUNCTION postgraphql.get_facebook_activists_by_message_date_interval(
    message text,
    date_interval_start timestamp,
    date_interval_end timestamp
)
    RETURNS setof postgraphql.facebook_activist_search_result_type
    LANGUAGE sql
    IMMUTABLE
AS $function$
    SELECT *
    FROM postgraphql.get_facebook_activists_by_date_interval(
        date_interval_start,
        date_interval_end
    )
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

CREATE OR REPLACE FUNCTION postgraphql.get_facebook_activists_by_message_quick_reply_date_interval(
    message text,
    quick_reply text,
    date_interval_start timestamp,
    date_interval_end timestamp
)
    RETURNS setof postgraphql.facebook_activist_search_result_type
    LANGUAGE sql
    IMMUTABLE
AS $function$
    SELECT *
    FROM postgraphql.get_facebook_activists_by_date_interval(
        date_interval_start,
        date_interval_end
    )
    WHERE
        messages @@ plainto_tsquery('portuguese', message) AND
        quick_reply = ANY(quick_replies)
    ORDER BY updated_at DESC;
$function$;
}
  end

  def down
    execute %Q{
DROP FUNCTION postgraphql.get_facebook_activists_by_message_quick_reply_date_interval(
    message text,
    quick_reply text,
    date_interval_start timestamp,
    date_interval_end timestamp
);
DROP FUNCTION postgraphql.get_facebook_activists_by_message_quick_reply(
    message text,
    quick_reply text
);
DROP FUNCTION postgraphql.get_facebook_activists_by_message_date_interval(
    message text,
    date_interval_start timestamp,
    date_interval_end timestamp
);
DROP FUNCTION postgraphql.get_facebook_activists_by_message(message text);
DROP FUNCTION postgraphql.get_facebook_activists_by_quick_reply_date_interval(
    quick_reply text,
    date_interval_start timestamp,
    date_interval_end timestamp
);
DROP FUNCTION postgraphql.get_facebook_activists_by_quick_reply(quick_reply text);
DROP FUNCTION postgraphql.get_facebook_activists_by_date_interval(
    date_interval_start timestamp,
    date_interval_end timestamp
);
DROP TYPE postgraphql.facebook_activist_search_result_type;
}
  end
end
