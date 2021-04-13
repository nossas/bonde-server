source 'https://rubygems.org'
ruby '2.4.6'

gem 'rails', '4.2.11'
gem 'rails-api'
gem 'spring', group: :development
gem 'pg'
#gem 'devise_token_auth'
#gem 'devise-jwt'
gem 'bcrypt', '3.1.11'
gem 'jwt'
# gem 'omniauth'
gem 'rack-cors', require: 'rack/cors'
gem 'carrierwave'
gem 'responders'
gem 'fog'
gem 'active_model_serializers'
#gem 'machinist', '>= 2.0'
gem 'machinist_redux', '>= 3.0.4'
gem 'pundit'
gem 'gibbon', '>= 2'
gem 'redis', '3.3.3'
gem 'sidekiq'
gem 'puma'
gem 'platform-api'
gem 'pagarme', '2.1.2'
gem 'has_scope'
gem 'postgres-copy'
gem 'statesman', '2.0.1'
gem "liquid"
gem 'acts-as-taggable-on', '~> 4.0'
gem 'aws-sdk', '~> 2'
gem 'net-dns'
gem 'whenever', require: false
gem 'codacy-coverage', require: false
gem 'codecov', '~> 0.2.0', :require => false, :group => :test
gem 'rubocop', require: false
gem 'nokogiri', ">= 1.10.8"

group :staging, :production do
  gem 'elastic-apm'
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

gem 'test_after_commit', :group => :test
group :test do
  gem 'webmock', '2.3.1'
  gem "fakeredis", require: "fakeredis/rspec"
  gem 'simplecov', require: false
end
