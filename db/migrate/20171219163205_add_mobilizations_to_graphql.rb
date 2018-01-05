class AddMobilizationsToGraphql < ActiveRecord::Migration
  def up
    execute %Q{
      CREATE OR REPLACE VIEW "postgraphql"."mobilizations" AS
      SELECT
        mobi.id,
        mobi.name,
        mobi.color_scheme,
        mobi.user_id,
        mobi.google_analytics_code,
        mobi.goal "mobilization_goal",
        mobi.header_font,
        mobi.body_font,
        mobi.facebook_share_title,
        mobi.facebook_share_description,
        mobi.facebook_share_image,
        mobi.slug,
        mobi.custom_domain,
        mobi.twitter_share_text,
        mobi.favicon,
        json_agg(b.*) as blocks,
        json_agg(json_build_object(
          'id', w.id,
          'block_id', w.block_id,
          'settings', w.settings,
          'kind', w.kind,
          'created_at', w.created_at,
          'updated_at', w.updated_at,
          'sm_size', w.sm_size,
          'md_size', w.md_size,
          'lg_size', w.lg_size,
          'mailchimp_segment_id', w.mailchimp_segment_id,
          'action_community', w.action_community,
          'exported_at', w.exported_at,
          'mailchimp_unique_segment_id', w.mailchimp_unique_segment_id,
          'mailchimp_recurring_active_segment_id', w.mailchimp_recurring_active_segment_id,
          'mailchimp_recurring_inactive_segment_id', w.mailchimp_recurring_inactive_segment_id,
          'goal', w.goal,
          'deleted_at', w.deleted_at
        )) as widgets
      FROM
        public.widgets w
        LEFT JOIN public.blocks b ON w.block_id = b.id
        LEFT JOIN public.mobilizations mobi ON mobi.id = b.mobilization_id
      WHERE
        mobi.deleted_at IS NULL
        AND b.deleted_at IS NULL
        AND w.deleted_at IS NULL
      GROUP BY mobi.id;

      GRANT SELECT ON postgraphql.mobilizations to common_user, admin, anonymous;
    }
  end

  def down
    execute %Q{
      DROP VIEW postgraphql.mobilizations;
    }
  end
end
