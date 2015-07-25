class Mobilizations::WidgetsController < ApplicationController
  respond_to :json

  def index
    @widgets = Widget.joins(:block).where(blocks: {mobilization_id: params[:mobilization_id]}).order(:id)
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
    params.require(:widget).permit(settings: [:content])
  end
end
