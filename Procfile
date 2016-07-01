web: bundle exec puma -C config/puma.rb
worker: env QUEUE=* bundle exec rake environment resque:work
