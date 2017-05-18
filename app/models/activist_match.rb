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
  has_one :community, through: :mobilization

  after_commit :async_update_mailchimp, on: :create

  def async_update_mailchimp
    MailchimpSyncWorker.perform_async(self.id, 'activist_match')
  end

  def update_mailchimp force_in_test: false
    if(!Rails.env.test?) || force_in_test
      subscribe_attributes =  {
        FNAME: self.firstname,
        LNAME: self.lastname,
        EMAIL: self.activist.email
      }

      subscribe_to_list(self.activist.email, subscribe_attributes)
      subscribe_to_segment(self.widget.mailchimp_segment_id, self.activist.email)

      update_member(self.activist.email, {
        groupings: groupings
      }) if groupings
    end
  end
end
