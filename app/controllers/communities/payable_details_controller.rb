class Communities::PayableDetailsController < ApplicationController
  before_action :skip_policy_scope
  has_scope :by_widget, :by_mobilization, :by_block

  def index
    authorize community, :can_handle_with_payables?
    render json: apply_scopes(community.payable_details).to_json
  end

  def community
    @community ||= Community.find(params[:community_id])
  end

  def self.policy_class
    CommunityPolicy
  end
end
