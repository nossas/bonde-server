class Notification < ActiveRecord::Base
  belongs_to :activist
  belongs_to :notification_template

  validates :activist, :notification_template, presence: true

  def self.notify!(activist_id, template_name, template_vars, from_community = false)
    notification_template = NotificationTemplate.find_by_label(template_name)
    create!(
      activist_id: activist_id,
      notification_template: notification_template,
      template_vars: template_vars.to_json
    )
  end
end
