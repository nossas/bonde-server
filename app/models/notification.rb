class Notification < ActiveRecord::Base
  belongs_to :activist
  belongs_to :user
  belongs_to :notification_template

  validates :notification_template, presence: true

  def self.notify!(to, template_name, template_vars, from_community = false, auto_deliver = true)
    notification_template = NotificationTemplate.find_by_label(template_name.to_s)
    params = {
      notification_template: notification_template,
      template_vars: template_vars.to_json
    }
    if to.is_a? User
      params[:user] = to 
    elsif to.is_a? Activist
      params[:activist] = to 
    elsif to.is_a? String
      params[:email] = to 
    else
      params[:activist_id] = to
    end
    n = create!(params)

    if auto_deliver
      n.reload
      job_id = n.deliver!
      Rails.logger.info "schedule notification #{notification_template.label} -> job_id #{job_id}"
    end
    n
  end

  def deliver!
    NotificationWorker.perform_async(self.id)
  end

  def deliver_without_queue
    mail.deliver_now!
  end

  def mail
    NotificationMailer.notify(self)
  end
end
