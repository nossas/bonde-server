namespace :timers do
  desc 'deliver all notifications that delivered_at is null and deliver_at is null'
  task process_pending_notifications: :environment do
    loop do
      Notification.where(delivered_at: nil, deliver_at: nil).find_each do |notification|
        notification.deliver
      end
      sleep 5
    end
  end
end
