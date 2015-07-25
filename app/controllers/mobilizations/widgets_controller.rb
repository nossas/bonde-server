class Mobilizations::WidgetsController < ApplicationController
  respond_to :json

  def index
    @widgets = Widget.joins(:block).where(blocks: {mobilization_id: params[:mobilization_id]}).order(:id)
    render json: @widgets
  end

  def update
    @widget = Widget.joins(:block).where(blocks: {mobilization_id: params[:mobilization_id]}, widgets: {id: params[:id]}).first
    @widget.update!(widget_params)
    render json: @widget.reload
  end

  private

  def widget_params
    params.require(:widget).permit(settings: [:content])
  end
end
