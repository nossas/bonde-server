class TemplateMobilization < ActiveRecord::Base
  include Shareable
  include Herokuable
  include Filterable

  validates :name, :user_id, :slug, presence: true
  belongs_to :user
  belongs_to :organization

end
