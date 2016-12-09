class CommunityUser < ActiveRecord::Base
  @@ROLES = ['Proprietário', 'Administrador', 'Participante']

  belongs_to :community
  belongs_to :user

  validates :role, :user, :community, presence: true
  validates :role, numericality: {greater_than: 0, less_than_or_equal_to: @@ROLES.count}

  def role_str
    @@ROLES[self.role-1] if self.role and self.role > 0 and self.role < @@ROLES.count
  end
end
