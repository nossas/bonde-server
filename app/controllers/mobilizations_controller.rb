class MobilizationsController < ApplicationController
  respond_to :json
  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  def index
    @mobilizations = policy_scope(Mobilization).all
    @mobilizations = @mobilizations.where(user_id: params[:user_id]) if params[:user_id].present?
    render json: @mobilizations
  end
end
