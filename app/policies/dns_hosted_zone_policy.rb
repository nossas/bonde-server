class DnsHostedZonePolicy < CommunityPolicy
  def permitted_attributes
    [:domain_name, :comment]
  end

  def check?
    record.community.users.includes @user
  end
end