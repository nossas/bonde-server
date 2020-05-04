class FormEntry < ActiveRecord::Base
  include Mailchimpable
  include TagAnActivistOmatic

  validates :widget, :fields, presence: true
  validates :complete_name, length: { in: 3..70 }, allow_blank: true
  validates :email, allow_blank: true, presence: false
  validates_format_of :email, with: /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z/ , if: "! ( self.email.nil? || self.email.blank? )"


  belongs_to :widget
  belongs_to :activist

  has_one :mobilization, through: :widget
  has_one :community, through: :mobilization

  before_create :link_activist

  after_commit :async_update_mailchimp, on: :create
  after_commit :send_email, on: :create
  after_commit :add_automatic_tags, on: :create


  def link_activist
    self.activist = (Activist.by_email(email) || create_activist(name: complete_name, email: email)) if email.present?
  end

  def fields_as_json
    JSON.parse(self.fields)
  end

  def first_name
    if decode_last_name == nil
      complete = decode_complete_name
      complete.split(' ')[0] if complete
    else
      field_decode ['nome', 'name', /^(nombre|first[\-\s]?name)/]
    end
  end

  def last_name
    if decode_last_name == nil
      complete = decode_complete_name
      (complete.split(' ')[1..-1]).join(' ') if complete
    else
      decode_last_name
    end
  end

  def complete_name
    "#{(first_name || '').strip} #{last_name || ''}".strip
  end

  def email
    value = field_decode [/e\-?mail/, /correo electronico/]
    value.strip unless value.nil?
  end

  def phone
    field_decode [/^(celular|mobile|portable)/ ]
  end

  def city
    field_decode [/^(cidade|city|ciudad)/]
  end

  def async_update_mailchimp
    MailchimpSyncWorker.perform_async(self.id, 'formEntry')
  end

  def update_mailchimp
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
      }) if groupings
    end
  end

  def send_email
    if self.email.present?
      FormEntryMailer.thank_you_email(self).deliver_later
    end
  end

  def generate_activist
    if activistable?
      activist_found = Activist.by_email self.email
      unless activist_found
        activist_found = Activist.new(name: "#{self.first_name.strip} #{self.last_name}".strip, email: self.email, city: self.city, phone: self.phone)
        activist_found.save!
      end
      self.activist = activist_found
      self.save!(validate: false)
    end
  end

  private

  def activistable?
    return false if first_name.nil? or email.nil?
    return ! (self.email =~ URI::MailTo::EMAIL_REGEXP).nil? unless  self.first_name.empty?
    false
  end

  def decode_last_name
    field_decode [/^(sobre[\s\-]?nome|surname|last[\s\-]?name|apellido)/]
  end

  def decode_complete_name
    field_decode ['nome', 'nome completo', 'nome e sobrenome', 'nombre', 'nombre completo', 'nombre y apellido', 'name', 'complete name', 'name and surname']
  end

  def field_decode list_field_names
    return_value = nil
    fields_as_json.each do |field|
      if field['label']
          return_value = (field['value']||'').strip  if in_list?(list_field_names, field['label'] )
      end
    end if fields
    return_value
  end

  def in_list? list_field_names, field_label
    in_list = false
    scanned = I18n.transliterate(field_label.downcase).scan(/([\w\d\s\-]+)(\s*\(?\s*\*\s*\)?)?$/)
    if scanned
      in_list = le_campo(list_field_names, scanned[0][0].strip) if scanned[0]
    end
    in_list
  end

  def le_campo list_field_names, scanned
    list_field_names.each do |field_name|
      if field_name.class == Regexp
        return true if scanned =~ field_name
      else
        return true if scanned.eql? field_name
      end
    end
    false
  end
end
