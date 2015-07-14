class Mobilizations::WidgetsController < ApplicationController
  def index
    @widgets = Widget.joins(:block).where(blocks: {mobilization_id: params[:mobilization_id]})
    render json: @widgets
  end
end
