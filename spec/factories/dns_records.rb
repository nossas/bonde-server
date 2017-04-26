FactoryGirl.define do
  factory :dns_record do
    dns_hosted_zone
    name { "www.#{dns_hosted_zone.domain_name}" }
    record_type "A"
    value "192.168.0.1"
    ttl 3600
  end
end
