RSpec.configure do |config|
  config.before :each do
    stub_request(:post, "https://api.heroku.com/apps/#{ENV['CLIENT_APP_NAME']}/domains")
    stub_request(:delete, "https://api.heroku.com/apps/#{ENV['CLIENT_APP_NAME']}/domains/")
  end
end
