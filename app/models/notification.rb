class Notification < ActiveRecord::Base
  belongs_to :activist
  belongs_to :community
  belongs_to :user
  belongs_to :notification_template

  validates :notification_template, presence: true

  def self.notify!(to, template_name, template_vars, from_community_id = nil, auto_deliver = true)
    notification_template = find_template_by_attributes(label: template_name.to_s, community_id: from_community_id) || find_template_by_attributes(label: template_name.to_s)

    raise StandardError.new "template name does not exists: #{template_name}" unless notification_template

    params = {
      notification_template: notification_template,
      template_vars: template_vars.to_json,
      community_id: from_community_id
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

    n = Notification.create!(params)

    if auto_deliver
      n.reload
      job_id = n.deliver!
      Rails.logger.info "schedule notification #{notification_template.label} -> job_id #{job_id}"
    end
    n
  end

  def self.find_template_by_attributes attrs
    NotificationTemplate.find_by attrs
  end

  def custom_from_email
    community.try(:email_template_from)
  end

  def deliver!
    NotificationWorker.perform_async(self.id)
  end

  def deliver_without_queue
    mail.deliver_now!
    update_column(:delivered_at, DateTime.now)
  end

  def mail
    NotificationMailer.notify(self)
  end
end
