FactoryGirl.define do
  factory :dns_record do
    dns_hosted_zone
    name "www"
    record_type "A"
    value "192.168.0.1"
    ttl 3600
  end
end
