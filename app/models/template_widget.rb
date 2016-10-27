class TemplateWidget < ActiveRecord::Base
  validates :sm_size, :md_size, :lg_size, :kind, presence: true
  validates :mailchimp_segment_id, uniqueness: true, allow_nil: true
  belongs_to :template_block
  has_one :mobilization, through: :template_block
  store_accessor :settings

  delegate :user, to: :template_mobilization

  def self.create_from(widget, templateBlock)
  	template = TemplateWidget.new
  	template.template_block = templateBlock
  	template.settings = widget.settings
  	template.kind = widget.kind
  	template.sm_size = widget.sm_size
  	template.md_size = widget.md_size
  	template.lg_size = widget.lg_size
  	template.mailchimp_segment_id = widget.mailchimp_segment_id
  	template.action_community = widget.action_community
  	template.exported_at = widget.exported_at
  	template
  end
end
