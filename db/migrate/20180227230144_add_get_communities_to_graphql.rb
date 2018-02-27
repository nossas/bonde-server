class AddGetCommunitiesToGraphql < ActiveRecord::Migration
  def up
    execute %Q{
      CREATE OR REPLACE VIEW "postgraphql"."communities" AS
       SELECT
          com.id,
          com.name,
          com.city,
          com.description,
          com.created_at,
          com.updated_at,
          com.mailchimp_api_key,
          com.mailchimp_list_id,
          com.mailchimp_group_id,
          com.image,
          com.recipient_id,
          com.facebook_app_id,
          com.fb_link,
          com.twitter_link,
          com.subscription_retry_interval,
          com.subscription_dead_days_interval,
          com.email_template_from,
          com.mailchimp_sync_request_at
         FROM public.communities com
          JOIN community_users AS cou ON cou.community_id = com.id
         WHERE cou.user_id = postgraphql.current_user_id();

      GRANT SELECT ON postgraphql.communities to common_user, admin;
    }
  end

  def down
    execute %Q{
      drop view postgraphql.communities;
    }
  end
end
