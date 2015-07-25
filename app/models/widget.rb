class Widget < ActiveRecord::Base
  validates :size, :kind, presence: true
  belongs_to :block
  has_one :mobilization, through: :block
  store_accessor :settings
end
