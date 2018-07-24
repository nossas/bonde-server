class NotificationsController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped
  before_filter :get_notification

  def show
    raise 'not found' unless Rails.env.staging? or Rails.env.development?
    notification = get_notification

    render html: notification.mail.body.to_s.html_safe, layout: 'layouts/notifications'
  end

  private
  def get_notification
    Notification.find params[:id]
  end
end
