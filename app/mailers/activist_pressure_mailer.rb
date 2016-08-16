class ActivistPressureMailer < ApplicationMailer
  def thank_you_email(activist_pressure)
    @activist = activist_pressure.activist
    @widget = activist_pressure.widget
    @mobilization = @widget.mobilization
    @settings = @widget.settings

    mail to: @activist.email, subject: subject, from: from
  end

  private
  def from
    has_sender = @settings['sender_name'] && @settings['sender_email']
    has_first_name = @mobilization.user.first_name

    if @settings.present?
      return "#{@mobilization.user.first_name} <#{@mobilization.user.email}>" if has_first_name
      return "#{@settings['sender_name']} <#{@settings['sender_email']}>" if has_sender
    end
    @mobilization.user.email
  end

  def subject
    return @settings['email_subject'] if @settings['email_subject']
    @mobilization.name
  end
end
