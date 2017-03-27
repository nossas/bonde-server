class Invitation < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  attr_readonly :community_id, :user_id, :email, :code, :role, :expires
 
  validates :community_id, :user_id, :email, :role, :expires, presence: true
  validates :code, uniqueness: { scope: [:community_id] }

  belongs_to :community
  belongs_to :user

  before_validation(on: :create) do
    self.code = Digest::MD5.hexdigest("#{community_id}-#{user_id}-#{email}-#{role}-#{created_at}")
  end

  def link
    accept_invitation_url({code: self.code, email: self.email})
  end

  def invitation_email
    CommunityMailer.invite_email(self).deliver_now
  end

  def create_community_user
    if invitation_expired?
      self.update_attributes expired: true if (! self.expired)
      raise InvitationException.new(I18n.t 'activerecord.errors.models.invitation.create_community_user')
    end
    CommunityUser.create user: self.user, community: self.community, role: self.role
  end

  private

  def invitation_expired?
    expired? || ( expires < DateTime.now )
  end
end

class InvitationException < RuntimeError
end