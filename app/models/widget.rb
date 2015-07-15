class Widget < ActiveRecord::Base
  validates :block_id, :size, :kind, presence: true
  belongs_to :block
end
