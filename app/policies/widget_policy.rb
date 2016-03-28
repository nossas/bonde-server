class WidgetPolicy < ApplicationPolicy
  def permitted_attributes
    if create?
      [:kind, settings: [:content, :call_to_action, :button_text, :count_text, :email_text, :action_community]]
    else
      []
    end
  end

  private

  def is_owned_by?(user)
    user.present? && record.mobilization.user == user
  end
end
