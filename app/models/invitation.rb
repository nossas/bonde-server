class Invitation < ActiveRecord::Base
  attr_readonly :community_id, :user_id, :email, :code, :role, :expires
 
  validates :community_id, :user_id, :email, :role, :expires, presence: true
  validates :code, uniqueness: { scope: [:community_id] }

  belongs_to :community
  belongs_to :user

  before_validation(on: :create) do
    self.code = Digest::MD5.hexdigest("#{community_id}-#{user_id}-#{email}-#{role}-#{created_at}")
  end

  def link
    ''
  end

  def invitation_email
    CommunityMailer.invite_email(self).deliver_now
  end
end
