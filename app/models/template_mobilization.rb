class TemplateMobilization < ActiveRecord::Base
  include Shareable
  include Herokuable
  include Filterable

  validates :name, :user_id, :slug, presence: true
  belongs_to :user
  belongs_to :organization

  has_many :template_blocks
  has_many :template_widgets, through: :template_blocks

end
