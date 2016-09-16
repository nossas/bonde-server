class Organizations::PayableDetailsController < ApplicationController
  before_action :skip_policy_scope

  def index
    authorize organization, :can_handle_with_payables?
    render json: organization.payable_details.to_json
  end

  def organization
    @organization ||= Organization.find(params[:organization_id])
  end

  def self.policy_class
    OrganizationPolicy
  end
end
