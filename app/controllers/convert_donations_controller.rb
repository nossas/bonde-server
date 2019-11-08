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
    t = Time.now
    t -= (60 * 60 * 24)

    email = params[:user_email]
    amount = params[:amount]

     widget = catch_widget 
     valid_donation = Donation.where('donations.email = ? and donations.transaction_status =  ? and donations.widget_id = ?', email, 'paid', widget.id).order("created_at DESC").first 
      
    if params[:utf8].present? && valid_donation.present? && Time.parse(valid_donation.created_at) > t
            
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
    @activist = valid_donation['customer'] 
    render 'replay' 
  end

  private

  def catch_widget
    Widget.find params[:widget_id]
  end
end
