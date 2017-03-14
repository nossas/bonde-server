FactoryGirl.define do
  factory :activist do
    name "Foo Bar"
    email "foo@bar.org"
    phone { { ddd: "11", number: "999999999" }.to_s }
    document_number "12345678909"
  end
end
