class PostbacksController < ApplicationController
  skip_before_filter :authenticate_user!

  def create
    if valid_postback?
      process_postback_for (params[:event] == 'subscription_status_changed' ? :subscription : :transaction)
      return render nothing: true, status: 200
    end

    render json: {error: 'invalid postback'}, status: 400
  end

  protected

  def process_postback_for resource_name
    case resource_name
    when :transaction then
      donation.try(:update_pagarme_data)
    when :subscription then
      sync_service = SubscriptionSyncService.new(params[:id])
      sync_service.sync(:last)
    end
  end

  def subscription
    @subscription ||= PagarMe::Subscription.find_by_id params[:id]
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
