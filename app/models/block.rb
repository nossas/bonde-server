class Block < ActiveRecord::Base
  validates :mobilization_id, presence: true
  belongs_to :mobilization
end
