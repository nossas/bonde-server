class Widget < ActiveRecord::Base
  include Mailchimpable

  validates :sm_size, :md_size, :lg_size, :kind, presence: true
  validates :mailchimp_segment_id, uniqueness: true, allow_nil: true
  belongs_to :block
  has_one :mobilization, through: :block
  has_many :form_entries
  has_many :donations
  has_many :matches
  store_accessor :settings

  after_create :create_mailchimp_segment, if: :is_mailchimpable?
  delegate :user, to: :mobilization

  def as_json(options = {})
    WidgetSerializer.new(self, {root: false})
  end

  def segment_name
    mob = self.mobilization
    mob_id = mob.id
    mob_name = mob.name

    return "M#{mob_id}C#{self.id} - [Comunidade] #{mob_name[0..89]}" if action_community?
    "M#{mob_id}A#{self.id} - #{mob_name[0..89]}"
  end

  def is_mailchimpable?
    self.form? || self.match?
  end

  def form?
    self.kind == "form"
  end

  def match?
    self.kind == "match"
  end

  def donation?
    self.kind == "donation"
  end

  def recurring?
    self.settings["payment_type"] != "unique" if self.settings
  end

  def donation_values
    s = self.settings
    values = []
    values_number = s.keys.count{|x| x =~ /^donation_value/}

    1.upto(values_number){|n| values << s["donation_value#{n}"]}
    values.delete("")
    values
  end

  def create_mailchimp_segment
    if !Rails.env.test?
      segment = create_segment(segment_name)
      self.update_attribute :mailchimp_segment_id, segment["id"]
    end
  end
end
