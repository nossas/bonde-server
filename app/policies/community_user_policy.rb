class CommunityUserPolicy < ApplicationPolicy
  def permitted_attributes
    [
      :user_id,
      :community_id,
      :role
    ]
  end

  def create?
    can_access?
  end

  def update?
    can_access?
  end

  def show?
    can_access?
  end

  private 

  def can_access?
    usr = CommunityUser.find_by(community_id: record.community_id, user_id: user.id)
    usr and (usr.role <= 2)
  end
end
