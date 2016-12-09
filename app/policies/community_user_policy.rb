class CommunityUserPolicy < ApplicationPolicy
  def permitted_attributes
    [
      :user_id,
      :community_id,
      :role
    ]
  end

  def create?
    usr = CommunityUser.find_by(community_id: record.community_id, user_id: user.id)
    usr and (usr.role <= 2)
  end
end
