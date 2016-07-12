class Widgets::MatchController < ApplicationController
  respond_to :json
  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  def create
    @match = Match.new(match_params.merge(widget_id: params[:widget_id]))
    authorize @match
    @match.save!
    render json: @match
  end

  def update
    @match = Match.where(widget_id: params[:widget_id], id: params[:id]).first
    authorize @match
    @match.update!(match_params)
    render json: @match
  end

  def destroy
    ###
    # NOT WORKING ):
    ###
    body = JSON.parse request.body.read
    column_hash = { body['column_name'] => body['value'] }
    @match = Match.where(column_hash, widget_id: params[:widget_id])
    authorize @match
    # @match.destroy!
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
