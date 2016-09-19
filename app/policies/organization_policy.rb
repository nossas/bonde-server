class OrganizationPolicy < ApplicationPolicy
  def can_handle_with_payables?
    is_owned_by?(user)
  end

  private

  def is_owned_by?(user)
    user.present? && record.users.include?(user)
  end
end
