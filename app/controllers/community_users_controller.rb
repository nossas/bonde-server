class CommunityUsersController < ApplicationController
  respond_to :json

  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :none


  def index
    community = Community.find_by({id: params[:community_id]})

    if community
      authorize community, :show?

      render json: community.community_users.map{|ur| { 
        user: {
          user_id: ur.user_id, 
          first_name: ur.user.first_name,
          last_name: ur.user.last_name,
          email: ur.user.email
        },
        role: ur.role_str
      } }
    else
      skip_authorization
      render nothing: true, :status => 404
    end
  end

end
