class Mobilizations::BlocksController < ApplicationController
  respond_to :json
  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  def index
    render json: policy_scope(Block).not_deleted.where(mobilization_id: params[:mobilization_id]).order(:position)
  end

  def create
    @block = Block.new(block_params.merge(mobilization_id: params[:mobilization_id]))
    authorize @block
    if @block.save
      render json: @block , serializer: BlockSerializer::CompleteBlockSerializer
    else
      render json: @block, status: :unprocessable_entity
    end
  end

  def update
    @block = Block.not_deleted.where(mobilization_id: params[:mobilization_id], id: params[:id]).first
    authorize @block
    @block.update!(block_params)
    render json: @block
  end

  def batch_update
    @block = Block.find(params[:blocks].first[:id])
    authorize @block

    if params[:blocks].count >= 2
      batch = Block.update_blocks(blocks_params[:blocks])

      if batch[:status] == 'success'
        render json: { blocks: batch }, status: 200
      else
        render json: { errors: batch.to_json }, status: :unprocessable_entity
      end
    else
      render json: { errors: 'must have two or more blocks in list' }, status: :unprocessable_entity
    end
  end

  def destroy
    @block = Block.where(mobilization_id: params[:mobilization_id], id: params[:id]).first
    authorize @block
    @block.update_attribute(:deleted_at, DateTime.now)
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

  def blocks_params
    if params[:blocks]
      params.permit(blocks: [:id, :bg_class, :position, :hidden, :bg_image, :name, :menu_hidden, :deleted_at])
    end
  end
end
