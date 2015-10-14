class BlocksController < ApplicationController
  respond_to :json
  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  def index
    @blocks = policy_scope(Mobilization).filter(params.slice(:custom_domain, :slug)).blocks
    render json: @blocks.order(:position)
  end
end
