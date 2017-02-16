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
end
