class DnsHostedZonePolicy < CommunityPolicy
  def permitted_attributes
    [:domain_name, :comment]
  end
end