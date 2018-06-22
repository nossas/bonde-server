class CreateUserCommunitiesToV2 < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE VIEW "postgraphql"."user_communities" AS
 SELECT com.id,
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
   FROM (communities com
     JOIN community_users cou ON ((cou.community_id = com.id)))
  WHERE (cou.user_id = postgraphql.current_user_id());

GRANT SELECT ON postgraphql.communities TO common_user, admin;
}
  end

  def down
    execute %Q{
drop database postgraphql.user_communities;
}
  end
end
