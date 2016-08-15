class FormEntry < ActiveRecord::Base
  include Mailchimpable

  validates :widget, :fields, presence: true
  belongs_to :widget
  has_one :mobilization, through: :widget
  has_one :organization, through: :mobilization

  after_create :update_mailchimp
  after_create :send_email

  def fields_as_json
    JSON.parse(self.fields)
  end

  def first_name
    fields_as_json.each do |field|
      if field['label'] && ['nome'].include?(field['label'].downcase)
        return field['value']
      end
    end
  end

  def last_name
    fields_as_json.each do |field|
      if field['label'] && ['sobrenome', 'sobre-nome', 'sobre nome'].include?(field['label'].downcase)
        return field['value']
      end
    end
  end

  def email
    fields_as_json.each do |field|
      if field['kind'] == 'email'
        return field['value']
      end
    end
  end

  def phone
    fields_as_json.each do |field|
      if field['label'] && ['celular'].include?(field['label'].downcase)
        return field['value']
      end
    end
  end

  def city
    fields_as_json.each do |field|
      if field['label'] && field['label'].downcase == 'cidade'
        return field['value']
      end
    end
  end


  def update_mailchimp
    if(!Rails.env.test?)
      subscribe_attributes =  {
        FNAME: self.first_name,
        LNAME: self.last_name,
        EMAIL: self.email,
        PHONE: self.phone || "",
        CITY: self.city,
        ORG: self.organization.name
      }

      if !self.city.present? || self.city.try(:downcase) == 'outra'
        subscribe_attributes.delete(:CITY)
      end

      subscribe_to_list(self.email, subscribe_attributes)

      subscribe_to_segment(self.widget.mailchimp_segment_id, self.email)

      update_member(self.email, {
        groupings: [{ id: ENV['MAILCHIMP_GROUP_ID'], groups: [self.organization.name] }]
      })
    end
  end

  def send_email
    if self.email.present?
      FormEntryMailer.thank_you_email(self).deliver_later
    end
  end
end
