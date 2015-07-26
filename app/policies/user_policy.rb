class UserPolicy < ApplicationPolicy
  def create?
    is_admin?
  end

  def update?
    is_admin?
  end

  def destroy?
    is_admin?
  end
end
