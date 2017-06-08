FactoryGirl.define do
  factory :notification_template do
    sequence(:label) { |x| "template_#{x}" }
    subject_template "hello {{name}}"
    body_template "World {{name}}"
  end
end
