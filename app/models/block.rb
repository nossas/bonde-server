class Block < ActiveRecord::Base
  validates :mobilization_id, :position, presence: true
  belongs_to :mobilization
  has_many :widgets
  accepts_nested_attributes_for :widgets

  before_validation :set_position
  after_save :switch_position

  after_save do
    mobilization.touch if mobilization.present?
  end

  scope :not_deleted, -> { where(deleted_at: nil) }

  private

  def set_position
    unless self.position.present? || self.mobilization.nil?
      self.position = (self.mobilization.blocks.where(deleted_at: nil).maximum(:position) || 0) + 1
    end
  end

  def switch_position
    block = self.mobilization.blocks.where("position >= ? and deleted_at is null and id <> ?", self.position, self.id).order(:position).first
    if block.present?
      block.update_attributes(position: block.position + 1)
    end
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
end
