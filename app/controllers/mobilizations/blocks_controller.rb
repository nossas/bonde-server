class Mobilizations::BlocksController < ApplicationController
  respond_to :json
  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  include ControllerHelper

  def index
    render json: policy_scope(Block).where(mobilization_id: params[:mobilization_id]).order(:position)
  end

  def create
    if Mobilization.find_by({id: params[:mobilization_id]})
      @block = Block.new(block_params.merge(mobilization_id: params[:mobilization_id]))
      authorize @block
      @block.save!
      render json: @block , serializer: BlockSerializer::CompleteBlockSerializer
    else
      render_status 400, ['Mobilization does not exist']
    end
  end

  def update
    @block = Block.where(mobilization_id: params[:mobilization_id], id: params[:id]).first
    if @block
      authorize @block
      @block.update!(block_params)
      render json: @block
    else
      render_404
    end
  end

  def destroy
    @block = Block.where(mobilization_id: params[:mobilization_id], id: params[:id]).first
    if @block
      authorize @block
      @block.destroy!
      render json: @block
    else
      render_404
    end
  end

  private

  def block_params
    if params[:block]
      params.require(:block).permit(*policy(@block || Block.new).permitted_attributes)
    else
      {}
    end
  end
end
