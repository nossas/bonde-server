[![CircleCI](https://circleci.com/gh/ourcities/hub-api.svg?style=svg&circle-token=2a4587154e7472e2ac2b77cc3a9f6f7e663035e0)](https://circleci.com/gh/ourcities/hub-api)
[![Test
Coverage](https://codeclimate.com/github/ourcities/hub-api/badges/coverage.svg)](https://codeclimate.com/github/ourcities/hub-api/coverage)

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
