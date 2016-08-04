class ActivistMatch < ActiveRecord::Base
  # include Mailchimpable
  #
  # validates :widget, presence: true
  # belongs_to :activist
  # belongs_to :match
  # has_one :widget, through: :match
  #
  # def update_mailchimp
  #   if(!Rails.env.test?)
  #     subscribe_attributes =  {
  #       FNAME: self.first_name,
  #       LNAME: self.last_name,
  #       EMAIL: self.email,
  #       PHONE: self.phone || "",
  #       CITY: self.city,
  #       ORG: self.organization.name
  #     }
  #
  #     if !self.city.present? || self.city.try(:downcase) == 'outra'
  #       subscribe_attributes.delete(:CITY)
  #     end
  #
  #     subscribe_to_list(self.email, subscribe_attributes)
  #
  #     subscribe_to_segment(self.widget.mailchimp_segment_id, self.email)
  #
  #     update_member(self.email, {
  #       groupings: [{ id: 49, groups: [self.organization.name] }]
  #     })
  #   end
  # end
end
