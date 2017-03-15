class NotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: :mailers

  def perform(notification_id)
    notification = Notification.find notification_id
    notification.deliver_without_queue
  end
end
