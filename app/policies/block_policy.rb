class BlockPolicy < ApplicationPolicy
  def permitted_attributes
    if create?
      [:position, :bg_class, :bg_image, :hidden, :name, :menu_hidden,
        widgets_attributes: [:kind, :goal, :sm_size, :md_size, :lg_size, settings: [
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
        :whatsapp_text,

        # Content Widget
        :content,

        # Pressure Widget
        :targets,
        :pressure_subject,
        :pressure_body,
        :reply_email,
        :show_city,

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
        :action_community,

        #finish messages
        :finish_message,
        :finish_message_type,
        :finish_message_background
        ]]]
    else
      []
    end
  end

  private

  def is_owned_by?(user)
    user.present? && record.mobilization.user == user
  end
end
