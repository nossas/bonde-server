class Block < ActiveRecord::Base
  validates :mobilization_id, :position, presence: true
  belongs_to :mobilization
  has_many :widgets
  accepts_nested_attributes_for :widgets

  before_validation :set_position
  before_save :switch_position

  private

  def set_position
    unless self.position.present? || self.mobilization.nil?
      self.position = (self.mobilization.blocks.maximum(:position) || 0) + 1
    end
  end

  def switch_position
    if self.position_changed?
      self.mobilization.blocks.where(position: position_change[1]).update_all(position: position_change[0])
    end
  end
end
