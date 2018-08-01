class Block < ActiveRecord::Base
  validates :mobilization_id, :position, presence: true
  belongs_to :mobilization
  has_many :widgets
  accepts_nested_attributes_for :widgets

  after_save do
    mobilization.touch if mobilization.present?
  end

  scope :not_deleted, -> { where(deleted_at: nil) }

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
          Block.where(id: block[:id])
            .update_all(position: block[:position])
        end
        return { blocks: blocks, status: 'success' }
      rescue ActiveRecord::RecordInvalid => e
        e
      end
    end
  end
end
