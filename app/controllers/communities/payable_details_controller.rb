class Organizations::PayableDetailsController < ApplicationController
  before_action :skip_policy_scope
  has_scope :by_widget, :by_mobilization, :by_block

  def index
    authorize organization, :can_handle_with_payables?
    render json: apply_scopes(organization.payable_details).to_json
  end

  def organization
    @organization ||= Organization.find(params[:organization_id])
  end

  def self.policy_class
    OrganizationPolicy
  end
end
