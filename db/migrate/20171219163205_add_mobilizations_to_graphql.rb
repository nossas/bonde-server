class AddMobilizationsToGraphql < ActiveRecord::Migration
  def up
    execute %Q{
    CREATE
    OR REPLACE VIEW postgraphql.mobilizations AS
    SELECT
      m.id "mobilization_id",
      m.name "mobilization_name",
      m.color_scheme,
      m.user_id,
      m.google_analytics_code,
      m.goal "mobilization_goal",
      m.header_font,
      m.body_font,
      m.facebook_share_title,
      m.facebook_share_description,
      m.facebook_share_image,
      m.slug,
      m.custom_domain,
      m.twitter_share_text,
      m.favicon,
      b.id "block_id",
      b.bg_class,
      b.position,
      b.hidden,
      b.bg_image,
      b.name "block_name",
      b.menu_hidden,
      w.id "widget+id",
      w.settings,
      w.kind,
      w.sm_size,
      w.md_size,
      w.lg_size,
      w.mailchimp_segment_id,
      w.action_community,
      w.exported_at,
      w.mailchimp_unique_segment_id,
      w.mailchimp_recurring_active_segment_id,
      w.mailchimp_recurring_inactive_segment_id,
      w.goal "widget_goal"
    FROM
      widgets w
      LEFT JOIN blocks b ON w.block_id = b.id
      LEFT JOIN mobilizations m ON b.mobilization_id = m.id
    WHERE m.deleted_at IS NULL
      AND b.deleted_at IS NULL
      AND w.deleted_at IS NULL;

    GRANT SELECT ON postgraphql.mobilizations
      TO common_user, admin, anonymous;
    }
  end

  def down
    execute %Q{
      DROP VIEW postgraphql.mobilizations;
    }
  end
end
