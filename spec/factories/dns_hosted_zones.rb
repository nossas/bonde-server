FactoryGirl.define do
  factory :dns_hosted_zone do
    community
    domain_name "nossas.org"
    comment "Nossas' domain"
    hosted_zone_id "4e123"
  end
end
