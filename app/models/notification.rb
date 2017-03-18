class Notification < ActiveRecord::Base
  belongs_to :activist
  belongs_to :notification_template

  validates :activist, :notification_template, presence: true

  def self.notify!(activist_id, template_name, template_vars, from_community = false, auto_deliver = true)
    notification_template = NotificationTemplate.find_by_label(template_name.to_s)
    create!(
      activist_id: activist_id,
      notification_template: notification_template,
      template_vars: template_vars.to_json
    )
    deliver! if auto_deliver
  end

  def deliver
    NotificationWorker.perform_async(self.id)
  end

  def deliver_without_queue
    NotificationMailer.notify(self).deliver_now!
  end
end