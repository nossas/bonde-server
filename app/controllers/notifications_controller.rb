class NotificationsController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped
  def show
    raise 'not found' unless Rails.env.staging? or Rails.env.development?
    notification = Notification.find params[:id]

    render html: notification.mail.body.to_s.html_safe, layout: 'layouts/mailer'
  end
end
