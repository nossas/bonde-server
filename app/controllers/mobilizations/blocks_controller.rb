class Mobilizations::BlocksController < ApplicationController
  respond_to :json

  def index
    render json: Block.where(mobilization_id: params[:mobilization_id]).order(:position)
  end

  def create
    @block = Block.create(block_params.merge(mobilization_id: params[:mobilization_id]))
    render json: @block
  end

  private

  def block_params
    if params[:block]
      params.require(:block).permit([:position, :bg_class, widgets_attributes: [:kind, :size]])
    else
      {}
    end
  end
end
