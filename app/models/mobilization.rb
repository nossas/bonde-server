class Mobilization < ActiveRecord::Base
  validates :name, :user_id, :color_scheme, presence: true
  belongs_to :user
  has_many :blocks
  has_many :widgets, through: :blocks
end
