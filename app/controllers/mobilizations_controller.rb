class MobilizationsController < ApplicationController
  respond_to :json
  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  def index
    @mobilizations = policy_scope(Mobilization).order('updated_at DESC')
    @mobilizations = @mobilizations.where(user_id: params[:user_id]) if params[:user_id].present?
    render json: @mobilizations
  end

  def create
    @mobilization = Mobilization.new(mobilization_params)
    @mobilization.user = current_user
    authorize @mobilization
    @mobilization.save!
    render json: @mobilization
  end

  def update
    @mobilization = Mobilization.find(params[:id])
    authorize @mobilization
    @mobilization.update!(mobilization_params)
    render json: @mobilization
  end

  def mobilization_params
    if params[:mobilization]
      params.require(:mobilization).permit(*policy(@mobilization || Mobilization.new).permitted_attributes)
    else
      {}
    end
  end
end
