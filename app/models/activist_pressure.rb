class ActivistPressure < ActiveRecord::Base
  include Mailchimpable

  attr_accessor :firstname, :lastname, :mail, :city

  validates :widget, :activist, :mail, presence: true
  belongs_to :activist
  belongs_to :widget
  has_one :block, through: :widget
  has_one :mobilization, through: :block
  has_one :organization, through: :mobilization

  after_create :async_update_mailchimp, :send_thank_you_email, :send_pressure_email, unless: :is_test?

  def as_json(*)
    ActivistPressureSerializer.new(self, {root: false})
  end

  def async_update_mailchimp
    Resque.enqueue(MailchimpSync, self.id, 'activist_pressure')
  end

  def update_mailchimp
    subscribe_to_list(self.activist.email, subscribe_attributes)
    subscribe_to_segment(self.widget.mailchimp_segment_id, self.activist.email)
    update_member(self.activist.email, { groupings: groupings })
  end

  def send_thank_you_email
    ActivistPressureMailer.thank_you_email(self.id).deliver_later
  end

  def send_pressure_email
    chunk = 100.0
    start = 0

    (self.mail[:cc].length / chunk).ceil.times do |times|
      mail = self.mail.dup
      mail[:cc] = mail[:cc][start...chunk * (times + 1)]
      start = chunk * (times + 1)
      ActivistPressureMailer.pressure_email(self.id, mail).deliver_later
    end
  end

  private

  def is_test?
    Rails.env.test?
  end

  def subscribe_attributes
    {
      FNAME: self.firstname,
      LNAME: self.lastname,
      EMAIL: self.activist.email
    }
  end

  def groupings
    [
      { id: ENV['MAILCHIMP_GROUP_ID'], groups: [self.organization.name] }
    ]
  end
end
