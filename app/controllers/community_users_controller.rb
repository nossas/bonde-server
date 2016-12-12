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

  def create
    @community_user = CommunityUser.new(community_user_params)
    @community_user.community_id = params['community_id']
    authorize @community_user
    if @community_user.validate
      @community_user.save!
      render json: @community_user
    else
      render json: @community_user.errors, :status => 400
    end
  end

  def update
    community_user = CommunityUser.find_by({id: params[:id]})
    if community_user
      community_user.role = params[:communityUser][:role]
      authorize community_user
      if community_user.validate
        community_user.save!
        render json: community_user
      else
        render json: community_user.errors, status: 400
      end
    else
      return404
    end
  end

  def destroy
    community_user = CommunityUser.find_by({id: params['id']})
    if community_user
      authorize community_user
      community_user.delete
      render nothing: true
    else
      return404
    end
  end

  private

  def return404
    skip_authorization
    render nothing: true, status: 404
  end

  def community_user_params
     params.require(:communityUser).permit(*policy(@community_user || CommunityUser.new).permitted_attributes)
  end
end
