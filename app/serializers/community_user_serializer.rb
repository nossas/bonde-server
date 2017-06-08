class CommunityUserSerializer < ActiveModel::Serializer
  attributes :id, :user, :role, :role_str

  def user
    {user_id:object.user_id, first_name: object.user.first_name, last_name: object.user.last_name, email: object.user.email}
  end
  
  class CommunityUserSimpleSerializer < ActiveModel::Serializer
    attributes :id, :user_id, :community_id, :role
  end
end
