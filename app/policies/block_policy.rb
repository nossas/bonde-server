class BlockPolicy < ApplicationPolicy
  def permitted_attributes
    if create?
      [:position, :bg_class, :hidden, widgets_attributes: [:kind, :size]]
    else
      []
    end
  end

  private

  def is_owned_by?(user)
    user.present? && record.mobilization.user == user
  end
end
