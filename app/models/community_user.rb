class CommunityUser < ActiveRecord::Base
  belongs_to :community
  belongs_to :user

  validates :role, :user, :community, presence: true
end
