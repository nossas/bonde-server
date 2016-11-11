
rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

Resque.logger.formatter = Resque::VeryVerboseFormatter.new
Resque.redis = ENV['REDIS_URL']
