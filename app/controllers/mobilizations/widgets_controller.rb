class Mobilizations::WidgetsController < ApplicationController
  respond_to :json

  def index
    @widgets = Widget.joins(:block).where(blocks: {mobilization_id: params[:mobilization_id]})
    render json: @widgets
  end
end
