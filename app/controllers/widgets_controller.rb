class WidgetsController < ApplicationController
  respond_to :json
  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  def index
    @widgets = policy_scope(Mobilization).filter(params.slice(:custom_domain, :slug)).widgets
    render json: @widgets.order(:id)
  end
end
