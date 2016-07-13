class MatchPolicy < ApplicationPolicy
  def permitted_attributes
    if create?
      [
      :first_choice,
      :second_choice,
      :goal_image
      ]
    else
      []
    end
  end

  private

  def is_owned_by?(user)
    user.present? && record.widget.mobilization.user == user
  end
end
