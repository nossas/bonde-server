class ActivistPressure < ActiveRecord::Base
  include Mailchimpable
  include TagAnActivistOmatic

  validates :widget, presence: true
  belongs_to :activist
  belongs_to :widget
  has_one :block, through: :widget
  has_one :mobilization, through: :block
  has_one :community, through: :mobilization

  after_commit :async_update_mailchimp, :send_thank_you_email, :send_pressure_email, on: :create, unless: :is_test?
  after_commit :add_automatic_tags, on: :create

  def as_json(*)
    ActivistPressureSerializer.new(self, {root: false})
  end

  def async_update_mailchimp
    MailchimpSyncWorker.perform_async(self.id, 'activist_pressure')
  end

  def update_mailchimp
    subscribe_to_list( self.activist.email, subscribe_attributes )
    subscribe_to_segment( self.widget.mailchimp_segment_id, self.activist.email )
    update_member( self.activist.email, { groupings: groupings } ) if groupings
  end

  def send_thank_you_email
    notify_thanks(:thank_you_activist_pressure)
  end

  def send_pressure_email
    self.mail["cc"].each do |recipient|
      notify_pressure(recipient, :pressure_template)
    end
  end

  def notify_thanks(template_name, template_vars = {}, auto_deliver = true, notification_type = 'auto_fire')
    Notification.notify!(
      activist_id,
      template_name,
      thanks_template_vars.merge(template_vars),
      community.id,
      auto_deliver,
      notification_type
    )
  end

  def notify_pressure(to, template_name, template_vars = {}, auto_deliver = true, notification_type = 'pressure')
    Notification.notify!(
      to,
      template_name,
      pressure_template_vars.merge(template_vars),
      community.id,
      auto_deliver,
      notification_type
    )
  end

  def thanks_template_vars
    global = {
      email_text: self.widget.settings['email_text'],
      from_address: self.widget.settings['sender_email'].nil? ? community.try(:email_template_from) : "#{self.widget.settings['sender_name']} <#{self.widget.settings['sender_email']}>",
      subject: self.widget.settings['email_subject'].nil? ? mobilization.try(:name) : self.widget.settings['email_subject']
    }
  end

  def pressure_template_vars
    global = {
      subject: self.mail["subject"],
      from_address: activist.present? ? "#{activist.name} <#{activist.email}>" : community.try(:email_template_from),
      pressure_id: self.id
    }
  end

  private

  def is_test?
    Rails.env.test?
  end

  def subscribe_attributes
    return_subscribe_attributes = {
      FNAME: self.firstname || self.activist.first_name,
      LNAME: self.lastname || self.activist.last_name,
      EMAIL: self.activist.email,
    }
    return_subscribe_attributes[:CITY] = self.activist.city if self.activist and self.activist.city
    return_subscribe_attributes
  end
end
