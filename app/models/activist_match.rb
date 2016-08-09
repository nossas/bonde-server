class ActivistMatch < ActiveRecord::Base
  include Mailchimpable

  attr_accessor :firstname
  attr_accessor :lastname

  validates :widget, :activist, presence: true
  belongs_to :activist
  belongs_to :match
  has_one :widget, through: :match
  has_one :block, through: :widget
  has_one :mobilization, through: :block
  has_one :organization, through: :mobilization

  after_create :update_mailchimp

  def update_mailchimp
    if(!Rails.env.test?)
      subscribe_attributes =  {
        FNAME: self.firstname,
        LNAME: self.lastname,
        EMAIL: self.activist.email
      }

      subscribe_to_list(self.activist.email, subscribe_attributes)
      subscribe_to_segment(self.widget.mailchimp_segment_id, self.activist.email)
      update_member(self.activist.email, {
        groupings: [{ id: ENV['MAILCHIMP_GROUP_ID'], groups: [self.organization.name] }]
      })
    end
  end
end
