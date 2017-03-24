class Invitation < ActiveRecord::Base
  validates :community_id,:user_id,:email,:code,:role,:expires,:expired, presence: true
  validates :code, uniqueness: { scope: [:community_id] }

  belongs_to :community
  belongs_to :user
end
