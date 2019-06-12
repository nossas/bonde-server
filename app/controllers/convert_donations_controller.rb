class ConvertDonationsController < ApplicationController
  respond_to :json
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped
  # before_filter :catch_widget

  def convert
    amount = params[:amount]

    donation = Donation.find params[:donation_id]

    if donation.present?
      donation.subscription = true
      donation.amount = amount if amount.present?
      donation.save

      DonationService.process_subscription(donation)

      return render json: donation
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def replay
    email = params[:user_email]
    # widget = Widget.find params[:widget_id]
    widget = catch_widget
    amount = params[:amount]

    valid_donation = Donation.where('donations.email = ? and donations.transaction_status =  ? and donations.widget_id = ? and donations.created_at::timestamp < (now() - interval \'24 hour\')', email, 'paid', widget.id).last
    if params[:utf8].nil? && valid_donation.present?
      valid_donation.converted_from = valid_donation.id
      valid_donation.id = nil
      valid_donation.transaction_id = nil
      valid_donation.transaction_status = nil
      valid_donation.card_hash = nil
      valid_donation.created_at = nil
      valid_donation.updated_at = nil
      valid_donation.widget_id = widget.id
      valid_donation.amount = amount if amount.present?
      valid_donation.mailchimp_syncronization_at = nil
      valid_donation.mailchimp_syncronization_error_reason = nil
      valid_donation.skip = true
      
      @donation = Donation.create(valid_donation.attributes)
      @donation.checkout_data = valid_donation[:customer]
      @donation.cached_community_id = @donation.try(:mobilization).try(:community_id)

      if @donation.save!
        address = @donation.activist.addresses.last 
        donation_service = DonationService.run(@donation, address)

        if donation_service == 'refused'
          render json: { transaction_status: donation_service }, status: :unprocessable_entity
        end
      else
        render json: @donation.errors, status: :unprocessable_entity
      end
      # else
      #   raise ActiveRecord::RecordNotFound
    end
    @activist = valid_donation.customer 
    render 'replay' 
  end

  private

  def catch_widget
    Widget.find params[:widget_id]
  end
end
