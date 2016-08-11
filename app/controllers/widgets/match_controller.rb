class Widgets::MatchController < ApplicationController
  respond_to :json
  before_action :load_widget
  before_action :authorize_action, except: %i[show]
  after_action :verify_authorized, except: %i[show]
  after_action :verify_policy_scoped, only: %i[index]

  def show
    @match = collection.find(params[:id])
    render json: @match.as_json.merge(:widget_title => @widget.settings['title_text'])
  end

  def create
    @match = collection.new(match_params)
    @match.save!
    render json: @match
  end

  def update
    @match = collection.find(params[:id])
    @match.update_attributes(match_params)
    render json: @match
  end

  def destroy
    @match = collection.find(params[:id])
    @match.destroy
    render json: { ok: true }
  end

  def delete_where
    if params[:match].present?
      @matches = collection.where(match_params)
      matches_ids = @matches.ids
      @matches.destroy_all
      render json: { ok: {
        widget_id: params[:widget_id],
        deleted_matches: matches_ids
      } }
    else
      render json: { ok: false }
    end
  end

  private

  def match_params
    if params[:match]
      params.require(:match).permit(*policy(@match || Match.new).permitted_attributes)
    else
      {}
    end
  end

  def collection
    @matches ||= @widget.matches
  end

  def load_widget
    @widget ||= Widget.find(params[:widget_id])
  end

  def authorize_action
    authorize @widget, :update?
  end
end
