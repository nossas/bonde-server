class Widget < ActiveRecord::Base
  validates :size, :kind, presence: true
  belongs_to :block
  store_accessor :settings
end
