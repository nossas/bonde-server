FactoryGirl.define do
  factory :facebook_bot_configuration do
    community ""
    messenger_app_secret "MyText"
    messenger_validation_token "MyText"
    messenger_page_access_token "MyText"
    data ""
  end
end
