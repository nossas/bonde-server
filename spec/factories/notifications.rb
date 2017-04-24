FactoryGirl.define do
  factory :notification do
    activist nil
    user nil
    email nil
    notification_template nil
    template_vars ""
  end
end
