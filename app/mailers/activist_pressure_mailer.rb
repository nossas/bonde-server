class ActivistPressureMailer < ApplicationMailer
  def thank_you_email(id)
    activist_pressure = load_model(id)
    @activist = activist_pressure.activist
    @widget = activist_pressure.widget
    @mobilization = @widget.mobilization
    @settings = @widget.settings

    mail to: @activist.email, subject: subject, from: from
  end

  def pressure_email(id, recipient)
    activist_pressure = load_model(id)
    @activist = activist_pressure.activist
    @mail = recipient
    mail to: targets, subject: @mail[:subject], from: activist_email
  end

  def load_model(id)
    ActivistPressure.find(id)
  end

  private
  def from
    has_sender = @settings.present? && @settings['sender_name'] && @settings['sender_email']
    has_first_name = @mobilization.user.first_name

    if @settings.present?
      return "#{@mobilization.user.first_name} <#{@mobilization.user.email}>" if has_first_name
      return "#{@settings['sender_name']} <#{@settings['sender_email']}>" if has_sender
    end
    @mobilization.user.email
  end

  def subject
    return @settings['email_subject'] if @settings.present? && @settings['email_subject']
    @mobilization.name
  end

  def targets
    @mail[:cc].join(',')
  end

  def activist_email
    return "#{@activist[:name]} <#{@activist[:email]}>" if @activist[:name]
    @activist[:email]
  end
end
