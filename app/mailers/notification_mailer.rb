class NotificationMailer < ApplicationMailer
  layout :mailer

  def notify(notification)
    @notification = notification
    @template = notification.notification_template

    configure_xsmtp_headers
    mail(mail_attributes)
  end

  private

  def subject
    @template.generate_subject(@notification.template_vars)
  end

  def body
    @template.generate_body(@notification.template_vars)
  end

  def mail_attributes
    {
      to: @notification.activist.email,
      subject: subject,
      body: body.html_safe,
      content_type: "text/html"
    }
  end

  def configure_xsmtp_headers
    headers['X-SMTPAPI'] = {
      unique_args: {
        notification_id: @notification.id,
        template_name: @notification.notification_template.label
      }
    }.to_json
  end
end
