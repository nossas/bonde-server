#!/bin/bash -e
REPO_URI="https://user:$FLYNN_KEY@git.v6jv.flynnhub.com/ourcities-rebu-server-develop.git"
if [[ "$CIRCLE_BRANCH" == "master" ]]; then
  REPO_URI="dokku@api-ssl.reboo.org:api-ssl"
fi

git fetch --unshallow origin

if [[ "$CIRCLE_BRANCH" == "master" ]]; then
  rm -rf ~/.dokku
  git clone https://github.com/dokku/dokku.git ~/.dokku
	git remote add dokku $REPO_URI
	GIT_SSL_NO_VERIFY=true git push -f dokku $CIRCLE_SHA1:refs/heads/master
  $HOME/.dokku/contrib/dokku_client.sh run "rake db:migrate"
else
	git remote add flynn $REPO_URI
	GIT_SSL_NO_VERIFY=true git push -f flynn $CIRCLE_SHA1:refs/heads/master

  L=/home/ubuntu/bin/flynn && curl -sSL -A "`uname -sp`" https://dl.flynn.io/cli | zcat >$L && chmod +x $L
  flynn -a ourcities-rebu-server-develop run rake db:migrate
fi
