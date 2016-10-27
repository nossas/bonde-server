class TemplateBlock < ActiveRecord::Base
  validates :template_mobilization_id, :position, presence: true
  belongs_to :template_mobilization
  has_many :template_widgets
  accepts_nested_attributes_for :template_widgets
end
