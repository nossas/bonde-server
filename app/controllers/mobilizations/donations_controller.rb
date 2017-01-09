class Mobilizations::DonationsController < ApplicationController
  respond_to :json
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: %i[index]

  def index
    @donations = policy_scope(Donation)
      .by_community(params[:community_id])
      .by_widget(params[:widget_id])

    authorize @donations

    respond_with do |format|
      format.json { render json: @donations }
      format.text { render text: @donations.to_txt, :type => 'text/csv', :disposition => 'inline', layout: false }
    end
  end

  def create
    @donation = Donation.new(donation_params)
    activist_params = donation_params[:customer]
    address_params = activist_params.delete(:address)

    authorize @donation

    if @donation.save!
      find_or_create_activist(activist_params)
      address = find_or_create_address(address_params)

      DonationService.run(@donation, address) unless @donation.subscription?
      SubscriptionService.run(@donation, address) if @donation.subscription?

      render json: @donation
    else
      render json: @donation.errors, status: :unprocessable_entity
    end
  end

  private

  def find_or_create_activist(activist_params)
    if activist = Activist.by_email(activist_params[:email])
      @donation.activist_id = activist.id
    else
      @donation.create_activist(activist_params)
    end
  end

  def find_or_create_address(address_params)
    @donation.activist.addresses.find_by(address_params) ||
      @donation.activist.addresses.create(address_params)
  end

  def donation_params
    params.require(:donation).permit(*policy(@donation || Donation.new).permitted_attributes).tap do |whitelisted|
      customer_params = params[:donation][:customer]
      if customer_params
        whitelisted[:donation][:customer] = customer_params
      end
    end
  end
end
