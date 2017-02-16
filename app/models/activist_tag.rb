class ActivistTag < ActiveRecord::Base
  acts_as_taggable

  belongs_to :activist
  belongs_to :community

  validates :activist, presence: true
  validates :community, presence: true
end
