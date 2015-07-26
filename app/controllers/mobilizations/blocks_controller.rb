class Mobilizations::BlocksController < ApplicationController
  respond_to :json
  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  def index
    render json: policy_scope(Block).where(mobilization_id: params[:mobilization_id]).order(:position)
  end

  def create
    @block = Block.new(block_params.merge(mobilization_id: params[:mobilization_id]))
    authorize @block
    @block.save!
    render json: @block
  end

  def update
    @block = Block.where(mobilization_id: params[:mobilization_id], id: params[:id]).first
    authorize @block
    @block.update!(block_params)
    render json: @block
  end

  def destroy
    @block = Block.where(mobilization_id: params[:mobilization_id], id: params[:id]).first
    authorize @block
    @block.destroy!
    render json: @block
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
