class Mobilizations::DonationsController < ApplicationController
  respond_to :json
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: %i[]

  def index
    @donations = policy_scope(Donation).by_widget(params[:widget_id])
    authorize @donations

    respond_with do |format|
      format.json { render json: @donations }
      format.text { render text: @donations.to_csv, :type => 'text/csv', :disposition => 'inline' }
    end
  end

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
    params.require(:donation).permit(*policy(@donation || Donation.new).permitted_attributes).tap do |whitelisted|
      customer_params = params[:donation][:customer]
      if customer_params
        whitelisted[:donation][:customer] = customer_params
      end
    end
  end
end
