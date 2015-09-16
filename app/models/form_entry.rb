class FormEntry < ActiveRecord::Base
  include Mailchimpable

  validates :widget, :fields, presence: true
  belongs_to :widget

  after_create :update_mailchimp

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
      if field['label'] && ['telefone', 'fone', 'celular'].include?(field['label'].downcase)
        return field['value']
      end
    end
  end

  def segment_name
    mobilization = self.widget.mobilization
    segment_name = "M#{mobilization.id}A#{self.widget_id} - #{mobilization.name[0..89]}"
  end

  def update_mailchimp
    if(!Rails.env.test?)
      subscribe_to_list(self.email, {
        FNAME: self.first_name,
        LNAME: self.last_name,
        EMAIL: self.email
      })
      segment = find_or_create_segment_by_name(self.segment_name)
      subscribe_to_segment(segment["id"], self.email)
    end
  end
end
