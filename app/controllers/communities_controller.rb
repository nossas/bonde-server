class CommunitiesController < ApplicationController
  respond_to :json

  include Pundit

  after_action :verify_authorized, except: [:index, :list_mobilizations]
  after_action :verify_policy_scoped, only: [:index, :list_mobilizations]

  def index
    skip_authorization
    skip_policy_scope

    render json: current_user.communities
  end


  def create
    @community = Community.new(community_params)
    authorize @community
    if not @community.validate
      render json: @community.errors, :status => 400
    else
      Community.transaction do 
        @community.save!
        create_role
        render json: @community
      end
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


  def show
    community = Community.find_by({id: params[:id]})
    if community
      authorize community
      render json: community
    else
      return404
    end
  end

  def list_activists
    skip_authorization
    skip_policy_scope

    community = Community.find params[:community_id]

    respond_with do |format|
      format.json do
        render json: community.agg_activists
      end
      format.csv do
        send_data community.agg_activists.copy_to_string, type: Mime::CSV, disposition: "attachment; filename=activists_#{community.name.parameterize}.csv"
      end
    end
  end

  def list_mobilizations
    community = Community.find_by({id: params['community_id']})

    if community
      begin
        @mobilizations = policy_scope(community.mobilizations).order('updated_at DESC')
        @mobilizations = @mobilizations.where(custom_domain: params[:custom_domain]) if params[:custom_domain].present?
        @mobilizations = @mobilizations.where(slug: params[:slug]) if params[:slug].present?
        @mobilizations = @mobilizations.where(id: params[:ids]) if params[:ids].present?
        render json: @mobilizations
      rescue StandardError => e
        Rails.logger.error e
      end
    else
      return404
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

  def create_role
    community_user = CommunityUser.new
    community_user.community = @community
    community_user.user = current_user
    community_user.role = 1
    community_user.save!
  end

  def return404
    skip_authorization
    skip_policy_scope
    render :status =>404, :nothing => true
  end
end
