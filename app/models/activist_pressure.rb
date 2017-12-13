class ActivistPressure < ActiveRecord::Base
  include Mailchimpable
  include TagAnActivistOmatic

  attr_accessor :firstname, :lastname, :mail

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
    ActivistPressureMailer.thank_you_email(self.id).deliver_later
  end

  def send_pressure_email
    self.mail[:cc].each do |recipient|
      mail = self.mail.dup
      mail[:cc] = recipient
      ActivistPressureMailer.pressure_email(self.id, mail).deliver_later
    end
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
