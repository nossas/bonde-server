#!/bin/bash -e

rm -rf ~/.dokku
git clone https://github.com/dokku/dokku.git ~/.dokku

DOKKU_HOST="reboo-staging.org"
if [[ "$CIRCLE_BRANCH" == "master" ]]; then
  DOKKU_HOST="reboo.org"
fi

REPO_URI="dokku@$DOKKU_HOST:api"
REPO_SSL="dokku@$DOKKU_HOST:api-ssl"

git remote add dokku $REPO_URI
git remote add dokku-ssl $REPO_SSL

git push dokku $CIRCLE_BRANCH:master
git push dokku-ssl $CIRCLE_BRANCH:master

$HOME/.dokku/contrib/dokku_client.sh run "rake db:migrate"

# PREV_WORKERS=$(heroku ps --app $APP_NAME | grep "^worker." | wc -l | tr -d ' ')
#
# # migrations require downtime so enter maintenance mode
# if test $MIGRATION_CHANGES -gt 0; then
#   heroku maintenance:on --app $APP_NAME
#
#   # Make sure workers are not running during a migration
#   heroku scale worker=0 --app $APP_NAME
# fi

# run database migrations if needed and restart background workers once finished
# if test $MIGRATION_CHANGES -gt 0; then
#   heroku run rake db:migrate db:seed --app $APP_NAME
#   heroku scale worker=$PREV_WORKERS --app $APP_NAME
#   heroku restart --app $APP_NAME
# fi
#
# heroku run rake cache:flush --app $APP_NAME
# heroku maintenance:off --app $APP_NAME
