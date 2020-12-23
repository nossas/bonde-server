[![CircleCI](https://circleci.com/gh/ourcities/hub-api.svg?style=svg&circle-token=2a4587154e7472e2ac2b77cc3a9f6f7e663035e0)](https://circleci.com/gh/ourcities/hub-api)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/1ea2ae75822243f49f0a180e0eb286c7)](https://www.codacy.com/app/Nossas/bonde-server?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=nossas/bonde-server&amp;utm_campaign=Badge_Grade)
[![Codacy Badge](https://api.codacy.com/project/badge/Coverage/1ea2ae75822243f49f0a180e0eb286c7)](https://www.codacy.com/app/Nossas/bonde-server?utm_source=github.com&utm_medium=referral&utm_content=nossas/bonde-server&utm_campaign=Badge_Coverage)

# Enviroment

```
# Install Rbenv
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc

# Install dependencies
apt-get install -y libssl-dev libreadline-dev build-essential zlib1g-dev
rbenv install 2.4.6

# Enter local folder, ex: cd nossas/bonde-server/
rbenv local 2.4.6
sudo apt-get install libpq-dev imagemagick libmagickwand-dev
rbenv exec gem install bundler -v 1.17.3
```

# Install
```
rbenv exec bundle
rbenv exec rake db:create db:migrate db:seed
rbenv exec bundle exec puma -C config/puma.rb
```
And the server is on fire :fire:

# Tests
```
DATABASE_URL=postgres://monkey_user:monkey_pass@10.0.0.12:5432/bonde_test bundle exec rspec spec
```

# Docker Commands

```
docker-compose exec pgmaster psql -Umonkey_user postgres -c "create database bonde_test"
docker-compose exec api-v1 bundle exec rake db:migrate DATABASE_URL=postgres://monkey_user:monkey_pass@10.0.0.12:5432/bonde_test RAILS_ENV=test 

```

And the green lights start to pop up :green_heart:
