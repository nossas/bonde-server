class ActivistPressure < ActiveRecord::Base
  include Mailchimpable

  attr_accessor :firstname, :lastname, :mail

  validates :widget, :activist, :mail, presence: true
  belongs_to :activist
  belongs_to :widget
  has_one :block, through: :widget
  has_one :mobilization, through: :block
  has_one :organization, through: :mobilization

  after_create :update_mailchimp, :send_thank_you_email, :send_pressure_email

  def as_json(options = {})
    ActivistPressureSerializer.new(self, {root: false})
  end

  def update_mailchimp
    unless Rails.env.test?
      subscribe_to_list(self.activist.email, subscribe_attributes)
      subscribe_to_segment(self.widget.mailchimp_segment_id, self.activist.email)
      update_member(self.activist.email, { groupings: groupings })
    end
  end

  def send_thank_you_email
    ActivistPressureMailer.thank_you_email(self).deliver_now
  end

  def send_pressure_email
    ActivistPressureMailer.pressure_email(self).deliver_now
  end

  private
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
