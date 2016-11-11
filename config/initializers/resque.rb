
rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

resque_config = YAML.load_file(rails_root + '/config/resque.yml')

Resque.logger.formatter = Resque::VeryVerboseFormatter.new
Resque.redis = resque_config[rails_env]

