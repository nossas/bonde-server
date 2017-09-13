class SaveFacebookBotActivistsData < ActiveRecord::Migration
  def up
    execute %Q{
GRANT SELECT, INSERT, UPDATE, DELETE ON public.facebook_bot_activists TO admin, common_user, anonymous;
GRANT USAGE ON SEQUENCE facebook_bot_activists_id_seq TO admin, common_user, anonymous;

CREATE OR REPLACE FUNCTION public.facebook_activist_message_full_text_index(v_message text)
    RETURNS tsvector
    LANGUAGE plpgsql
AS $function$
    BEGIN
        RETURN setweight(to_tsvector('portuguese', v_message), 'A');
    END;
$function$;

CREATE OR REPLACE FUNCTION public.update_facebook_bot_activists_full_text_index()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $function$
    DECLARE
        v_facebook_bot_activists public.facebook_bot_activists;
        v_payload jsonb;
        v_quick_reply text;
        v_messages tsvector;
        v_quick_replies text[];
    BEGIN
        SELECT *
        FROM public.facebook_bot_activists
        WHERE fb_context_recipient_id = NEW.fb_context_recipient_id
        INTO v_facebook_bot_activists;

        IF NEW.interaction ->> 'is_bot' IS NULL THEN
            v_payload := NEW.interaction -> 'payload';
            v_quick_reply := v_payload -> 'message' -> 'quick_reply' ->> 'payload';
            v_messages := CASE WHEN v_quick_reply IS NULL THEN
                public.facebook_activist_message_full_text_index(
                    v_payload -> 'message' ->> 'text'
                )
            END;

            IF v_quick_reply IS NOT NULL THEN
                v_quick_replies := ARRAY[v_quick_reply]::text[];
            END IF;

            IF v_facebook_bot_activists IS NULL THEN
                INSERT INTO public.facebook_bot_activists (
                    fb_context_recipient_id,
                    fb_context_sender_id,
                    data,
                    messages,
                    quick_replies,
                    interaction_dates,
                    created_at,
                    updated_at
                ) VALUES (
                    NEW.fb_context_recipient_id,
                    NEW.fb_context_sender_id,
                    NEW.interaction -> 'profile',
                    v_messages,
                    COALESCE(v_quick_replies, ARRAY[]::text[]),
                    ARRAY[NEW.created_at]::timestamp without time zone[],
                    NEW.created_at,
                    NEW.updated_at
                );
            ELSE
                UPDATE public.facebook_bot_activists
                SET
                    interaction_dates = ARRAY_APPEND(interaction_dates, NEW.created_at),
                    messages = CASE WHEN v_quick_reply IS NULL THEN messages || v_messages
                    ELSE messages
                    END,
                    quick_replies = CASE WHEN v_quick_replies IS NOT NULL THEN
                        (SELECT ARRAY_AGG(DISTINCT qr)
                        FROM UNNEST(ARRAY_CAT(quick_replies, v_quick_replies)) as qr)
                    ELSE
                        quick_replies
                    END
                WHERE fb_context_recipient_id = NEW.fb_context_recipient_id;
            END IF;
        END IF;
        RETURN NEW;
    END;
$function$;

CREATE TRIGGER update_facebook_bot_activist_data AFTER
INSERT OR UPDATE ON public.activist_facebook_bot_interactions
FOR EACH ROW EXECUTE PROCEDURE public.update_facebook_bot_activists_full_text_index();
}
  end

  def down
    execute %Q{
DROP TRIGGER IF EXISTS update_facebook_bot_activist_data
ON public.activist_facebook_bot_interactions;

DROP FUNCTION public.update_facebook_bot_activists_full_text_index();

DROP FUNCTION public.facebook_activist_message_full_text_index(v_message text);

REVOKE SELECT, INSERT, UPDATE, DELETE ON public.facebook_bot_activists FROM admin, common_user, anonymous;
REVOKE USAGE ON SEQUENCE facebook_bot_activists_id_seq FROM admin, common_user, anonymous;
}
  end
end
