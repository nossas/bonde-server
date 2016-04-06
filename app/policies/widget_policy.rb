class WidgetPolicy < ApplicationPolicy
  def permitted_attributes
    if create?
      [:kind, settings: [
        :content,
        :call_to_action,
        :button_text,
        :count_text,
        :email_text,

        :title_text,
        :main_color,
        :donation_value1,
        :donation_value2,
        :donation_value3,
        :donation_value4,
        :donation_value5,
        :payment_methods,
        :customer_data
        ]
      ]
    else
      []
    end
  end

  private

  def is_owned_by?(user)
    user.present? && record.mobilization.user == user
  end
end
#116588043
