FactoryGirl.define do
  factory :notification_template do
    label "template_1"
    subject_template "hello {{name}}"
    body_template "World {{name}}"
  end
end
