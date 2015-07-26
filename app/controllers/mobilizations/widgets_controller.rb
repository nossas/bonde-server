class Mobilizations::WidgetsController < ApplicationController
  respond_to :json
  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  def index
    @widgets = policy_scope(Widget).joins(:block).where(blocks: {mobilization_id: params[:mobilization_id]}).order(:id)
    render json: @widgets
  end

  def update
    @widget = Widget.find(params[:id])
    authorize @widget
    @widget.update!(widget_params)
    render json: @widget
  end

  private

  def widget_params
    params.require(:widget).permit(*policy(@widget || Widget.new).permitted_attributes)
  end
end
