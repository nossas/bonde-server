class ConvertDonationsController < ApplicationController
  respond_to :json
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped
  before_filter :catch_widget

  def convert
    email = params[:user_email]
    # widget = Widget.find params[:widget_id]
    widget = catch_widget
    amount = params[:amount]

    donation = widget.donations.joins(:activist).
                 where('activists.email = ? and subscription is null or not subscription', email).last

    if donation.present?
      new_donation = Donation.new(donation.attributes)
      new_donation.id = nil
      new_donation.subscription = true
      new_donation.amount = amount if amount.present?
      new_donation.converted_from = donation.id
      new_donation.save

      address = new_donation.activist.addresses.last
      SubscriptionService.run(new_donation, address)

      return render json: new_donation
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

    if valid_donation.present?
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
        address = find_or_create_address(valid_donation['activist_id'])
        donation_service = DonationService.run(@donation, address)

        if donation_service == 'refused'
          render json: { transaction_status: donation_service }, status: :unprocessable_entity
        else
          render 'replay' 
        end
      else
        render json: @donation.errors, status: :unprocessable_entity
      end
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  private

  def find_or_create_address(activist_id)
    @donation.activist.addresses.find(activist_id)
  end

  def catch_widget
    Widget.find params[:widget_id]
  end
end
