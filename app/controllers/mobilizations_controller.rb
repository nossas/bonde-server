class MobilizationsController < ApplicationController
  def index
    @mobilizations = Mobilization.all
    @mobilizations = Mobilization.where(user_id: params[:user_id]) if params[:user_id].present?
    render json: @mobilizations
  end
end
