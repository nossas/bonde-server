class Mobilization < ActiveRecord::Base
  include Shareable
  include Herokuable
  include Filterable

  validates :name, :user_id, :goal, :slug, presence: true
  validates :slug, uniqueness: true
  belongs_to :user
  has_many :blocks
  has_many :widgets, through: :blocks

  before_validation :slugify
  before_save :set_custom_domain

  def url
    "#{ENV["CLIENT_URL"]}/mobilizations/#{self.id}"
  end

  private

  def slugify
    self.slug ||= "#{self.class.count}-#{self.name.try(:parameterize)}"
  end

  def set_custom_domain
    return unless self.custom_domain_changed?
    delete_domain(self.custom_domain_was)
    create_domain({hostname: self.custom_domain})
  end
end
