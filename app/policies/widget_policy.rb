class WidgetPolicy < ApplicationPolicy
  def permitted_attributes
    if create?
      [:kind, settings: [
        # Can re-use settings
        # Autofire config
        :email_text,
        :email_subject,
        :sender_name,
        :sender_email,

        # Generic widget config
        :title_text,
        :main_color,
        :button_text,
        :count_text,
        :show_counter,

        # Settings specific widget
        # Content Widget
        :content,

        # Pressure Widget
        :targets,
        :pressure_subject,
        :pressure_body,

        # Donation widget
        :default_donation_value,
        :donation_value1,
        :donation_value2,
        :donation_value3,
        :donation_value4,
        :donation_value5,
        :recurring_period,
        :payment_type,
        :payment_methods,
        :customer_data,

        # Match Widget
        :choicesA,
        :choices1,
        :labelChoices1,
        :labelChoicesA,

        :call_to_action,
        :action_community
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
