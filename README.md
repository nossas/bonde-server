[![Build Status](https://travis-ci.org/ourcities/hub-api.svg?branch=master)](https://travis-ci.org/ourcities/hub-api)
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
