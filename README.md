[![CircleCI](https://circleci.com/gh/ourcities/hub-api.svg?style=svg&circle-token=2a4587154e7472e2ac2b77cc3a9f6f7e663035e0)](https://circleci.com/gh/ourcities/hub-api)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/1ea2ae75822243f49f0a180e0eb286c7)](https://www.codacy.com/app/Nossas/bonde-server?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=nossas/bonde-server&amp;utm_campaign=Badge_Grade)
[![Codacy Badge](https://api.codacy.com/project/badge/Coverage/1ea2ae75822243f49f0a180e0eb286c7)](https://www.codacy.com/app/Nossas/bonde-server?utm_source=github.com&utm_medium=referral&utm_content=nossas/bonde-server&utm_campaign=Badge_Coverage)

# Install
```
bundle
rake db:create db:migrate db:seed
bundle exec puma -C config/puma.rb
```
And the server is on fire :fire:

# Tests
```
rake spec
```
And the green lights start to pop up :green_heart:
