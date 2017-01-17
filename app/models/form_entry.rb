require './app/resque_jobs/mailchimp_sync.rb'

class FormEntry < ActiveRecord::Base
  include Mailchimpable

  validates :widget, :fields, presence: true

  belongs_to :widget
  belongs_to :activist

  has_one :mobilization, through: :widget
  has_one :community, through: :mobilization

  before_create :link_activist

  after_create :async_send_to_mailchimp
  after_create :send_email

  def link_activist
    self.activist = (Activist.by_email(email) || create_activist(name: first_name, email: email)) if email.present?
  end

  def fields_as_json
    JSON.parse(self.fields)
  end

  def first_name
    field_decode ['nome', 'nombre']
  end

  def last_name
    field_decode ['sobrenome', 'sobre-nome', 'sobre nome']
  end

  def email
    field_decode ['email']
  end

  def phone
    field_decode ['celular']
  end

  def city
    field_decode ['cidade']
  end

  def async_send_to_mailchimp
    Resque.enqueue(MailchimpSync, self.id, 'formEntry')
  end

  def send_to_mailchimp
    if(!Rails.env.test?)
      subscribe_attributes =  {
        FNAME: self.first_name,
        LNAME: self.last_name || "",
        EMAIL: self.email,
        PHONE: self.phone || "",
        CITY: self.city,
        ORG: self.community.name
      }

      if !city.present? || city.try(:downcase) == 'outra'
        subscribe_attributes.delete(:CITY)
      end

      subscribe_to_list(self.email, subscribe_attributes)
      subscribe_to_segment(self.widget.mailchimp_segment_id, self.email)
      update_member(self.email, {
        groupings: groupings
      })
    end
  end

  def send_email
    if self.email.present?
      FormEntryMailer.thank_you_email(self).deliver_later
    end
  end

  private

  def field_decode list_field_names
    fields_as_json.each do |field|
      if field['label'] && list_field_names.include?(field['label'].downcase)
        return field['value']
      end
    end if fields
    nil
  end
end
