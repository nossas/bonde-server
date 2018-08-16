class Notification < ActiveRecord::Base
  belongs_to :activist
  belongs_to :community
  belongs_to :user
  belongs_to :notification_template

  validates :notification_template, presence: true

  def self.notify!(to, template_name, template_vars, from_community_id = nil, auto_deliver = true, auto_fire = false)
    notification_template = find_template_by_attributes(label: template_name.to_s, community_id: from_community_id) || find_template_by_attributes(label: template_name.to_s)

    raise StandardError.new "template name does not exists: #{template_name}" unless notification_template

    params = {
      notification_template: notification_template,
      template_vars: template_vars.to_json,
      community_id: from_community_id,
      auto_fire: auto_fire
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
    if self.auto_fire
      template_vars['from_address']
    else
      community.try(:email_template_from)
    end
  end

  def deliver
    deliver! unless delivered_at.present?
  end

  def deliver!
    NotificationWorker.perform_async(self.id)
  end

  def deliver_without_queue
    transaction do
      update_column(:delivered_at, DateTime.now)
      if self.auto_fire
        auto_fire_mail.deliver_now!
      else
        mail.deliver_now!
      end
    end
  end

  def mail
    NotificationMailer.notify(self)
  end

  def auto_fire_mail
    NotificationMailer.auto_fire(self)
  end
end
