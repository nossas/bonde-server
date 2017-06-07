class User < ActiveRecord::Base
  has_many :mobilizations
  has_many :community_users
  has_many :communities, through: :community_users

  # mount_uploader :avatar, AvatarUploader

  validates :provider, :uid, :email, presence: true

  def as_json(_options = {})
    UserSerializer.new(self, {root: false})
  end

  def password=(new_password)
    @password = new_password
    self.encrypted_password = digest(@password) if @password.present?
  end

  private

  def digest(password)
    ::BCrypt::Password.create(password, cost: 11).to_s
  end
end
