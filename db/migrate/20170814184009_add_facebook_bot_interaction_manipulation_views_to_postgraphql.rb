class AddFacebookBotInteractionManipulationViewsToPostgraphql < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE VIEW postgraphql.facebook_bot_interactions AS
SELECT *
FROM public.activist_facebook_bot_interactions
WHERE interaction -> 'is_bot' = 'true';

GRANT SELECT ON postgraphql.facebook_bot_interactions
TO ADMIN, common_user, anonymous;


CREATE OR REPLACE VIEW postgraphql.facebook_activist_interactions AS
SELECT *
FROM public.activist_facebook_bot_interactions
WHERE interaction -> 'is_bot' IS NULL;

GRANT SELECT ON postgraphql.facebook_activist_interactions
TO ADMIN, common_user, anonymous;
}
  end

  def down
    execute %Q{
DROP VIEW postgraphql.facebook_activist_interactions;
DROP VIEW postgraphql.facebook_bot_interactions;
}
  end
end
