class CommunitiesController < ApplicationController
  respond_to :json

  include Pundit
  
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    skip_authorization
    skip_policy_scope

    render json: Community.order(:city)
  end

  def create
    @community = Community.new(community_params)
    authorize @community
    if not @community.validate
      render json: @community.errors, :status => 400
    else
      @community.save!
      render json: @community
    end
  end


  def update
    @community = Community.find_by({id: params[:id]})
    if not @community
      return404
    else
      authorize @community
      @community.update!(community_params)
      render json: @community
    end
  end

  private 

  def community_params
    if params[:community]
      params.require(:community).permit(*policy(@community || Community.new).permitted_attributes)
    else
      {}
    end
  end

  def return404
    skip_authorization
    render :status =>404, :nothing => true
  end
end
