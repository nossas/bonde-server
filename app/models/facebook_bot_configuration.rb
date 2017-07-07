class FacebookBotConfiguration < ActiveRecord::Base
  validates :messenger_app_secret, :messenger_validation_token, :messenger_page_access_token, presence: true
end
