class Block < ActiveRecord::Base
  validates :mobilization_id, :position, presence: true
  belongs_to :mobilization
  has_many :widgets
  accepts_nested_attributes_for :widgets

  before_validation do
    unless self.position.present? || self.mobilization.nil?
      self.position = self.mobilization.blocks.count + 1
    end
  end  
end
