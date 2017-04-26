class Widget < ActiveRecord::Base
  include Mailchimpable

  validates :sm_size, :md_size, :lg_size, :kind, presence: true
  validates :mailchimp_segment_id, uniqueness: true, allow_nil: true

  belongs_to :block

  has_one :community, through: :mobilization
  has_one :mobilization, through: :block

  has_many :form_entries
  has_many :donations
  has_many :matches
  has_many :activist_pressures

  store_accessor :settings

  delegate :user, to: :mobilization

  after_save do
    mobilization.touch if mobilization.present?
  end

  def as_json(*)
    WidgetSerializer.new(self, {root: false})
  end

  def segment_name
    kinds_correlation = {'pressure' => 'P', 'form' => 'F', 'match' => 'M', 'donation' => 'D'}

    mob = self.mobilization
    mob_id = mob.id
    mob_name = mob.name

    return "M#{mob_id}C#{self.id} - [Comunidade] #{mob_name[0..89]}" if action_community?
    "M#{mob_id}#{kinds_correlation[self.kind] || 'A'}#{self.id} - #{mob_name[0..89]}"
  end

  def form?
    self.kind == 'form'
  end

  def match?
    self.kind == 'match'
  end

  def donation?
    self.kind == 'donation'
  end

  def pressure?
    self.kind == 'pressure'
  end

  def recurring?
    self.settings['payment_type'] != 'unique' if self.settings
  end

  def synchro_to_mailchimp?
    self.form? or self.match? or self.donation?  or self.pressure?
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
    if self.synchro_to_mailchimp?
      segment = create_segment(segment_name)
      self.update_attribute :mailchimp_segment_id, segment.body["id"]
    end
  end
  
  def self.create_from template, block_instance
    widget = Widget.new
    widget.block = block_instance
    widget.settings = template.settings
    widget.kind = template.kind
    widget.sm_size = template.sm_size
    widget.md_size = template.md_size
    widget.lg_size = template.lg_size
    widget.action_community = template.action_community
    widget.exported_at = template.exported_at
    widget
  end
end
