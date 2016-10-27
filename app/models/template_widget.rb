class TemplateWidget < ActiveRecord::Base
  validates :sm_size, :md_size, :lg_size, :kind, presence: true
  validates :mailchimp_segment_id, uniqueness: true, allow_nil: true
  belongs_to :template_block
  has_one :mobilization, through: :template_block
  store_accessor :settings

  delegate :user, to: :template_mobilization
end
