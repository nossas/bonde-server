class Widget < ActiveRecord::Base
  validates :sm_size, :md_size, :lg_size, :kind, presence: true
  belongs_to :block
  has_one :mobilization, through: :block
  store_accessor :settings
end
