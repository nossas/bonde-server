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

    invited_user = User.find_by_email self.email
    #invited_user = generate_user unless invited_user

    if invited_user
      community_user = CommunityUser.create! user: invited_user, community: self.community, role: self.role
      self.expired = true
      self.save!

      community_user
    end
  end

  private

  def generate_user
    invited_user = User.new( provider: :email, uid: self.email, email: self.email, admin: true)
    invited_user.password = ((0...8).map { (65 + rand(26)).chr }.join)
    invited_user.save!
    invited_user
  end

  def invitation_expired?
    expired? || ( expires < DateTime.now )
  end
end

class InvitationException < RuntimeError
end