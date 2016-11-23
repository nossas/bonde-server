class UserPolicy < ApplicationPolicy
  def create?
    true
  end

  def permitted_attributes
    [:first_name, :last_name, :email, :avatar]
  end

  private

  def is_owned_by?(user)
    record.id == user.id
  end
end
