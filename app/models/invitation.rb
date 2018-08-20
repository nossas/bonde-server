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
    invitation_mailer(:community_invite)
  end

  def invitation_mailer(template_name, template_vars = {}, auto_deliver = true, auto_fire = true)
    Notification.notify!(
      self.email,
      template_name,
      invitation_template_vars.merge(template_vars),
      community.id,
      auto_deliver,
      auto_fire
    )
  end

  def invitation_template_vars
    global = {
      invited_user: {
        first_name: User.find_by_email(self.email).present? ? User.find_by_email(self.email).first_name : ''
      },
      invitation: {
        link: self.link,
        community_name: self.community.name
      }
    }
  end

  def create_community_user
    invited_user = User.find_by_email self.email

    if invited_user
       if invitation_expired?
         self.update_attributes expired: true if (! self.expired)
         return
       end

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
