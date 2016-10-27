class TemplateBlock < ActiveRecord::Base
  validates :template_mobilization_id, :position, presence: true
  belongs_to :template_mobilization
  has_many :template_widgets
  accepts_nested_attributes_for :template_widgets

  def self.create_from(block, templateMobilization)
  	template_block = TemplateBlock.new
  	template_block.template_mobilization = templateMobilization
    template_block.bg_class = block.bg_class
    template_block.hidden = block.hidden
    template_block.bg_image = block.bg_image
    template_block.name = block.name
    template_block.position = block.position
    template_block.menu_hidden = block.menu_hidden
    block.widgets.each do |widget|
    	template_block.template_widgets << TemplateWidget.create_from(widget, template_block)
    end
  	template_block
  end
end
