class Mobilizations::DonationsController < ApplicationController
  respond_to :json
  after_action :verify_policy_scoped, only: %i[]

  def create
    @donation = Donation.new(donation_params)
    authorize @donation
    if @donation.save!
      render json: @donation
    else
      render json: @donation.errors, status: :unprocessable_entity
    end
  end

  private

  def donation_params
    params.require(:donation).permit(*policy(@donation || Donation.new).permitted_attributes)
  end
end
