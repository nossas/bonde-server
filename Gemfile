source 'https://rubygems.org'
ruby '2.3.0'

gem 'rails', '4.2.5.2'
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
gem 'gibbon', '1.1.5'
gem 'resque', "~> 2.0.0.pre.1", github: "resque/resque"
gem 'puma'
gem 'platform-api'
gem 'appsignal'
gem 'codeclimate-test-reporter', group: :test, require: nil
gem 'pagarme', '2.1.2'

group :production do
  gem 'newrelic_rpm', '3.15.0.314'
  gem 'rails_stdout_logging'
end

group :test, :development do
  gem 'rspec-rails'
  gem 'rspec-activemodel-mocks'
  gem 'shoulda-matchers'
end

group :test do
  gem 'webmock'
end
