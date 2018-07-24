FactoryGirl.define do
  factory :activist, class: Activist do
    sequence(:name) { |n| "Activist #{n}" }
    sequence(:email) { |n| "activist#{n}@nossas.org" }
    phone { { ddd: "11", number: "999999999" }.to_s }
    document_number { "12345678909" }
  end

  factory :activist_tag, class: ActivistTag do
    activist
    community
  end

  factory :address, class: Address do
    activist
    zipcode { "0000000" }
    street { "Street" }
    street_number { "000" }
    complementary { "house" }
    neighborhood { "Neighborhood" }
    city { "City" }
    state { "AA" }
  end
end