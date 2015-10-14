class Mobilization < ActiveRecord::Base
  include Shareable
  include Filterable

  validates :name, :user_id, :goal, :slug, presence: true
  validates :slug, uniqueness: true
  belongs_to :user
  has_many :blocks
  has_many :widgets, through: :blocks

  before_validation :slugify

  def url
    "#{ENV["CLIENT_URL"]}/mobilizations/#{self.id}"
  end


  private

  def slugify
    self.slug = "#{self.class.count}-#{self.name}"
  end
end
