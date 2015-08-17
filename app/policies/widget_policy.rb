class WidgetPolicy < ApplicationPolicy
  def permitted_attributes
    if create?
      [:kind, settings: [:content]]
    else
      []
    end
  end

  private

  def is_owned_by?(user)
    user.present? && record.mobilization.user == user
  end
end
