class Mobilization < ActiveRecord::Base
  validates :name, :user_id, presence: true
  belongs_to :user
  has_many :blocks
  has_many :widgets, through: :blocks
end
