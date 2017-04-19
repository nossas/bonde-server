class PostbacksController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def create
    if valid_postback?
      resource_name = (params[:event] == 'subscription_status_changed' ? :subscription : :transaction)
      process_postback_for resource_name
      return render nothing: true, status: 200
    end

    render json: {error: 'invalid postback'}, status: 400
  end

  protected

  def process_postback_for resource_name
    case resource_name
    when :transaction then
      donation_state_was = donation.transaction_status_was.dup
      donation.try(:update_pagarme_data)
      process_subscription_changes(donation_state_was) if donation.subscription_relation.present?
    when :subscription then
      sync_service = SubscriptionSyncService.new(params[:id])
      sync_service.sync(:last)
    end
  end

  def process_subscription_changes(donation_state_was)
    donation.reload
    if donation_state_was != donation.transaction_status
      donation.subscription_relation.process_status_changes(donation.transaction_status, donation.gateway_data)
    end
  end

  def donation
    @donation ||= Donation.find_by(transaction_id: params[:id])
  end

  def valid_postback?
    raw_post  = request.raw_post
    signature = request.headers['HTTP_X_HUB_SIGNATURE']
    PagarMe::Postback.valid_request_signature?(raw_post, signature)
  end
end
