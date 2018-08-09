class BlocksController < ApplicationController
  respond_to :json
  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  def index
    mobilization = policy_scope(Mobilization).filter(params.slice(:custom_domain, :slug))
    mobilization = mobilization.first if mobilization.kind_of?(Array)
    blocks = mobilization.present? ? mobilization.blocks.order(:position) : []
    render json: blocks
  end
end
