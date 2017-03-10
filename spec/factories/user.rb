FactoryGirl.define do
  factory :user, class: User do
    sequence(:first_name) { |n| "Firstname #{n}" }
    sequence(:last_name) { |n| "Lastname #{n}"}
    sequence(:email) { |n| "email#{n}@trashmail.com" }
    uid { "#{email}" }
    provider { "email" }
    password { "12345678" }
  end
end
