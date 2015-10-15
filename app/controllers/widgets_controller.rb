class WidgetsController < ApplicationController
  respond_to :json
  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  def index
    mobilization = policy_scope(Mobilization).filter(params.slice(:custom_domain, :slug))
    widgets = mobilization.present? ? mobilization.widgets.order(:id) : []
    render json: widgets
  end
end
