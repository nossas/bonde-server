FactoryGirl.define do
  factory :dns_hosted_zone do
    community
    domain_name "nossas.org"
    comment "Nossas' domain"
  end
end
