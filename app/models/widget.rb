class Widget < ActiveRecord::Base
  include Mailchimpable

  validates :sm_size, :md_size, :lg_size, :kind, presence: true
  validates :mailchimp_segment_id, uniqueness: true, allow_nil: true
  belongs_to :block
  has_one :mobilization, through: :block
  has_many :form_entries
  store_accessor :settings

  after_create :create_mailchimp_segment, if: :form?

  def as_json(options = {})
    WidgetSerializer.new(self, {root: false})
  end

  def segment_name
    "M#{self.mobilization.id}A#{self.id} - #{self.mobilization.name[0..89]}"
  end

  def form?
    self.kind == "form"
  end

  def create_mailchimp_segment
    if !Rails.env.test?
      segment = create_segment(segment_name)
      self.update_attribute :mailchimp_segment_id, segment["id"]
    end
  end
end
