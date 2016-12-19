class User < ActiveRecord::Base
  has_many :mobilizations
  has_many :community_users
  has_many :communities, through: :community_users 

  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable, :omniauthable
  include DeviseTokenAuth::Concerns::User

  # mount_uploader :avatar, AvatarUploader

  validates :provider, :uid, :email, presence: true

  def as_json(_options = {})
    UserSerializer.new(self, {root: false})
  end
end
