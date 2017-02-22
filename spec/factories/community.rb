FactoryGirl.define do
  factory :community, class: Community do
    sequence(:name) { |n| "Community #{n}" }
  end
end