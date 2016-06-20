web: bundle exec puma -C config/puma.rb
worker: QUEUE=* bundle exec rake environment resque:work
