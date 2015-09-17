class Mobilization < ActiveRecord::Base
  include Shareable

  validates :name, :user_id, :goal, presence: true
  belongs_to :user
  has_many :blocks
  has_many :widgets, through: :blocks

  def url
    "#{ENV["CLIENT_URL"]}/mobilizations/#{self.id}"
  end
end
