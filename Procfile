web: bundle exec puma -C config/puma.rb
mailers: env QUEUE=mailers bundle exec rake environment resque:work
worker: env QUEUE=* bundle exec rake environment resque:work
