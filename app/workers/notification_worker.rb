class NotificationWorker
  include Sidekiq::Worker

  def perform(notification_id)
    notification = Notification.find notification_id
    Rails.logger.info "NotificationWorker runinng on notification #{notification.id}"
    notification.deliver_without_queue
  end
end
