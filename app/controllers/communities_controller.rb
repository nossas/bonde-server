class CommunitiesController < ApplicationController
  respond_to :json

  def index
    skip_authorization
    skip_policy_scope

    render json: Community.order(:city)
  end
end
