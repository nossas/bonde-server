class Communities::DonationReportsController < ApplicationController
  respond_to :json
  before_action :skip_policy_scope
  has_scope :by_widget, :by_mobilization_id

  def index
    authorize community, :can_handle_with_payables?
    collection = apply_scopes(community.donation_reports)

    respond_with do |format|
      format.json do
        render json: collection
      end
      format.csv do
        send_data collection.copy_to_string, type: Mime::CSV, disposition: "attachment; filename=donations_reports_#{DateTime.now.to_i}_#{community.name.parameterize}.csv"
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
