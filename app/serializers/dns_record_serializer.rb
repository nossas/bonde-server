class DnsRecordSerializer < ActiveModel::Serializer
  attributes :id, :dns_hosted_zone_id, :name, :record_type, :value, :ttl
end
