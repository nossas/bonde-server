class SubscriptionsController < ApplicationController
  def recharge
    if subscription.current_state == 'unpaid'
      if params[:process_at].present?
        SubscriptionWorker.perform_at(params[:process_at], subscription.id)
      elsif params[:card_hash].present?
        subscription.charge_next_payment(params[:card_hash])
      end
    end
    subscription.reload
    render json: subscription.to_json
  end

  protected

  def subscription
    subscription ||= Subscription.find params[:id]
  end
end
