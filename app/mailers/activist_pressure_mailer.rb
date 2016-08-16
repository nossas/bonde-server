class ActivistPressureMailer < ApplicationMailer
  def thank_you_email(activist_pressure)
    @activist = activist_pressure.activist
    @widget = activist_pressure.widget
    @mobilization = @widget.mobilization
    settings = @widget.settings
    pressure = activist_pressure.pressure

    from_address = @mobilization.user.email
    from_address = "#{@mobilization.user.first_name} <#{@mobilization.user.email}>" if @mobilization.user.first_name
    subject = @mobilization.name

    if settings.present?
      hasSender = settings['sender_name'] && settings['sender_email']

      from_address = "#{settings['sender_name']} <#{settings['sender_email']}>" if hasSender
      subject = settings['email_subject'] if settings['email_subject']
    end

    mail(
      to: @activist.email,
      subject: subject,
      from: from_address
    )
  end
end
