class CommunityUser < ActiveRecord::Base
  @@ROLES = ['Proprietário', 'Administrador', 'Participante']

  belongs_to :community
  belongs_to :user

  validates :role, :user, :community, presence: true
  validates :role, numericality: {greater_than: 0, less_than_or_equal_to: @@ROLES.count}

  validates_uniqueness_of :user, scope: [:user_id, :community_id]

  def role_str
    @@ROLES[self.role-1] if self.role and self.role > 0 and self.role < @@ROLES.count
  end

  def self.create_from_invitation invitation
    communityUser = CommunityUser.create user:invitation.user, community: invitation.community, role: invitation.role
    communityUser
  end
end
