class OrganizationsController < ApplicationController
  respond_to :json

  def index
    skip_authorization
    skip_policy_scope

    render json: Organization.order(:city)
  end
end
