class Communities::ActivistActionsController < ApplicationController
  respond_to :json
  before_action :skip_policy_scope
  has_scope :by_widget, :by_mobilization_id

  def index
    authorize community, :can_handle_with_activist_actions?
    collection = apply_scopes(community.activist_actions.order(action_created_at: :desc))

    respond_with do |format|
      format.json do
        render json: collection
      end
      format.csv do
        send_data collection.copy_to_string, type: Mime::CSV, disposition: "attachment; filename=activist_actions_#{DateTime.now.to_i}_#{community.name.parameterize}.csv"
      end
    end
  end

  def community
    @community ||= Community.find(params[:community_id])
  end

  def self.policy_class
    CommunityPolicy
  end
end
