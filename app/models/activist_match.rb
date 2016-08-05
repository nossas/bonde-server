class ActivistMatch < ActiveRecord::Base
  include Mailchimpable

  validates :widget, :activist, presence: true
  belongs_to :activist
  belongs_to :match
  has_one :widget, through: :match

  def update_mailchimp
    if(!Rails.env.test?)
      subscribe_attributes =  {
        FNAME: self.activist.name,
        EMAIL: self.activist.email
      }

      subscribe_to_list(self.email, subscribe_attributes)
      subscribe_to_segment(self.widget.mailchimp_segment_id, self.email)
      update_member(self.email, {
        groupings: [{ id: 49, groups: [self.organization.name] }]
      })
    end
  end
end
