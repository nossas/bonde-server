class Widgets::MatchController < ApplicationController
  respond_to :json
  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  def index
    render json: policy_scope(Match).where(widget_id: params[:widget_id])
  end

  def create
    @match = Match.new(match_params.merge(widget_id: params[:widget_id]))
    authorize @match
    @match.save!
    render json: @match
  end

  private

  def match_params
    if params[:match]
      params.require(:match).permit(*policy(@match || Match.new).permitted_attributes)
    else
      {}
    end
  end
end
