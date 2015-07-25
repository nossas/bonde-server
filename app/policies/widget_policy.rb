class WidgetPolicy < ApplicationPolicy
  def update?
    user.try(:admin?) || record.mobilization.user == user
  end
end
