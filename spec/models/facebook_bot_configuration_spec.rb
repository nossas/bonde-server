require 'rails_helper'

RSpec.describe FacebookBotConfiguration, type: :model do
  it { should validate_presence_of :messenger_app_secret }
  it { should validate_presence_of :messenger_validation_token }
  it { should validate_presence_of :messenger_page_access_token }
end
