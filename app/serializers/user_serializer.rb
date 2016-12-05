class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name, :uid, :provider, :avatar_url, :thumb_url

  def avatar_url
    object.avatar.url
  end

  def thumb_url
    object.avatar.thumb.url
  end
end
