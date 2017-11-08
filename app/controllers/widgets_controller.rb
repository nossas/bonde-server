class WidgetsController < ApplicationController
  respond_to :json
  after_action :verify_authorized, except: %i[index action_opportunities]
  after_action :verify_policy_scoped, only: %i[index action_opportunities]

  # FIXME efficiency
  def index
    mobilization = policy_scope(Mobilization).not_deleted.filter(params.slice(:custom_domain, :slug))
    mobilization = mobilization.first if mobilization.kind_of?(Array)
    widgets = mobilization.present? ? mobilization.widgets.not_deleted.order(:id) : Widget.none
    render json: widgets
  end

  def action_opportunities
    widgets = policy_scope(Widget).where(kind: 'form')
    render json: widgets
  end
end
