web: bundle exec puma -C config/puma.rb
mailers: bundle exec sidekiq -q mailers -c 5
worker: bundle exec sidekiq -c 5 -q mailchimp_synchro -q default
