class ActivistsController < ApplicationController
  before_action :load_community

  def add_activists
    render_status :unauthorized and return unless current_user
    authorize @community
    skip_policy_scope
    csv = request.body
    @return_list = Activist.update_from_csv_content csv, @community.id
    render json: @return_list
  end

  private

  def load_community
    @community = Community.find_by_id params[:community_id]
  end

  def render_status status
    render status: status, nothing:true
  end
end
