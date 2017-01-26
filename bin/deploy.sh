#!/bin/bash -e
REPO_URI="dokku@reboo-staging.org:api-ssl"
if [ ! -z "$CIRCLE_TAG" ]; then
  REPO_URI="dokku@api-ssl.reboo.org:api-ssl"
fi

git fetch --unshallow origin
git remote add dokku $REPO_URI
git push -f dokku $CIRCLE_SHA1:refs/heads/master

rm -rf ~/.dokku
git clone https://github.com/dokku/dokku.git ~/.dokku
$HOME/.dokku/contrib/dokku_client.sh run "./bin/rake db:migrate"
