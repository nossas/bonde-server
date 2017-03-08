source 'https://rubygems.org'
ruby '2.3.0'

gem 'rails', '4.2.7.1'
gem 'rails-api'
gem 'spring', group: :development
gem 'pg'
gem 'devise_token_auth'
gem 'omniauth'
gem 'rack-cors', require: 'rack/cors'
gem 'carrierwave'
gem 'rmagick'
gem 'fog'
gem 'active_model_serializers'
gem 'machinist', '>= 2.0.0.beta2'
gem 'pundit'
gem 'gibbon', '>= 2'
gem 'redis', '3.3.0'
gem 'resque', '1.26.0', require: 'resque/server'
gem 'sidekiq'
gem 'puma'
gem 'platform-api'
gem 'codeclimate-test-reporter', '< 1.0.0', group: :test, require: nil
gem 'pagarme', '2.1.2'
gem 'sentry-raven'
gem 'has_scope'
gem 'postgres-copy'

group :staging, :production do
  gem 'newrelic_rpm', '3.15.0.314'
  gem 'rails_stdout_logging'
end

group :test, :development do
  gem 'rspec-rails'
  gem 'rspec-activemodel-mocks'
  gem 'shoulda-matchers', '< 3.0.0'
  gem 'byebug'
  gem 'pry'
  gem 'factory_girl_rails', '~> 4.8'
end

group :test do
  gem 'webmock', '2.3.1'
  gem "fakeredis", :require => "fakeredis/rspec"
end
