class ActivistsController < ApplicationController
  before_action :load_community

  def add_activists
    authorize @community
    skip_policy_scope
    csv = request.body
    @return_list = Activist.update_from_csv_content csv
    render json: @return_list
  end

  def load_community
    @community = Community.find_by_id params[:community_id]
  end
end
