class TemplateBlock < ActiveRecord::Base
  validates :template_mobilization_id, :position, presence: true
  belongs_to :template_mobilization
end
