class ActivistPressureMailer < ApplicationMailer
  def thank_you_email(id, force_tests = false)
    if (!Rails.env.test?) or force_tests
      activist_pressure = load_model(id)
      @activist = activist_pressure.activist
      @widget = activist_pressure.widget
      @mobilization = @widget.mobilization
      @settings = @widget.settings

      mail to: @activist.email, subject: subject, from: from
    end
  end

  def pressure_email(id, recipient, force_tests = false)
    if (!Rails.env.test?) or force_tests
      activist_pressure = load_model(id)
      @activist = activist_pressure.activist
      @mail = recipient
      headers['X-SMTPAPI'] = {
        filters: {
          subscriptiontrack: {
            settings: {
              enable: 0
            }
          },
          bypass_list_management: {
            settings: {
              enable: 1
            }
          }
        }
      }.to_json
      mail to: targets, subject: @mail[:subject], from: activist_email
    end
  end

  def load_model(id)
    ActivistPressure.find(id)
  end

  private
  def from
    has_sender = @settings.present? && @settings['sender_name'] && @settings['sender_email']
    has_first_name = @mobilization.user.first_name

    if @settings.present?
      return "#{@settings['sender_name']} <#{@settings['sender_email']}>" if has_sender
      return "#{@mobilization.user.first_name} <#{@mobilization.user.email}>" if has_first_name
    end
    @mobilization.user.email
  end

  def subject
    return @settings['email_subject'] if @settings.present? && @settings['email_subject']
    @mobilization.name
  end

  def targets
    #@mail[:cc].join(',')
    @mail[:cc]
  end

  def activist_email
    return "#{@activist[:name]} <#{@activist[:email]}>" if @activist[:name]
    @activist[:email]
  end
end
