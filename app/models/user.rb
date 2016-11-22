class User < ActiveRecord::Base
  has_many :mobilizations

  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable, :omniauthable
  include DeviseTokenAuth::Concerns::User

  mount_uploader :avatar, AvatarUploader

  validates :provider, :uid, :email, presence: true

  def as_json(_options = {})
    UserSerializer.new(self, {root: false})
  end
end
