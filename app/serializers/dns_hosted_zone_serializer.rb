class DnsHostedZoneSerializer < ActiveModel::Serializer
  attributes :id, :community_id, :domain_name, :comment, :hosted_zone_id, :delegation_set_servers
end
