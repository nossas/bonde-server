class Match < ActiveRecord::Base
  belongs_to :widget
  has_one :block, through: :widget
  has_one :mobilization, through: :block
end
