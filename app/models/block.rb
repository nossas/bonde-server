class Block < ActiveRecord::Base
  validates :mobilization_id, :position, presence: true
  belongs_to :mobilization
  has_many :widgets
  accepts_nested_attributes_for :widgets
  default_scope -> { where(deleted_at: nil) }

  after_save do
    mobilization.touch if mobilization.present?
  end

  def self.create_from template, mobilization_instance
    block = Block.new
    block.mobilization = mobilization_instance
    block.bg_class = template.bg_class
    block.position = template.position
    block.hidden = template.hidden
    block.bg_image = template.bg_image
    block.name = template.name
    block.menu_hidden = template.menu_hidden
    block
  end

  def self.update_blocks(blocks)
    Block.transaction do
      begin
        blocks.each do |block|
          b = Block.find block[:id]
          b.update(block)
        end
        return { blocks: blocks, status: 'success' }
      rescue ActiveRecord::RecordInvalid => e
        e
      end
    end
  end
end
