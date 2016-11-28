#!/bin/bash -e
REPO_URI="https://ubuntu:$FLYNN_KEY@git.v6jv.flynnhub.com/ourcities-rebu-server-develop.git"
if [[ "$CIRCLE_BRANCH" == "master" ]]; then
  REPO_URI="dokku@api-ssl.reboo.org:api-ssl"
fi

git fetch --unshallow origin

git remote add deploy $REPO_URI

GIT_SSL_NO_VERIFY=true git push -f deploy $CIRCLE_SHA1:refs/heads/master

if [[ "$CIRCLE_BRANCH" == "master" ]]; then
  rm -rf ~/.dokku
  git clone https://github.com/dokku/dokku.git ~/.dokku
  $HOME/.dokku/contrib/dokku_client.sh run "rake db:migrate"
else
  L=/usr/local/bin/flynn && curl -sSL -A "`uname -sp`" https://dl.flynn.io/cli | zcat >$L && chmod +x $L
  flynn run rake db:migrate
fi
