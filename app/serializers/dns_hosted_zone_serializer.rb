class DnsHostedZoneSerializer < ActiveModel::Serializer
  attributes :id, :community_id, :domain_name, :comment, :hosted_zone_id, :delegation_set_servers, :ns_ok

  def ns_ok
    object.ns_ok?
  end
end
