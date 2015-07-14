class Mobilizations::BlocksController < ApplicationController
  before_action :set_mobilization
  respond_to :json

  def index
    render json: @mobilization.blocks
  end

  private

  def set_mobilization
    @mobilization = Mobilization.find(params[:mobilization_id])
  end

end
