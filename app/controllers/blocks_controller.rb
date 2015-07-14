class BlocksController < ApplicationController
  def index
    @blocks = Block.where(mobilization_id: params[:mobilization_id])
    render json: @blocks
  end
end
