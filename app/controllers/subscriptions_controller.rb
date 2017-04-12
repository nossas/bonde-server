class SubscriptionsController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def show
    render json: subscription, serializer: SubscriptionSerializer
  end

  def destroy
    subscription.transition_to(:canceled) unless subscription.canceled?
    render json: subscription, serializer: SubscriptionSerializer
  end

  def recharge
    if subscription.current_state == 'unpaid'
      if params[:process_at].present?
        SubscriptionWorker.perform_at(params[:process_at], subscription.id)
      elsif params[:card_hash].present?
        subscription.charge_next_payment(params[:card_hash])
      end
    end
    subscription.reload
    render json: subscription, serializer: SubscriptionSerializer
  end

  protected

  def subscription
    subscription ||= Subscription.find_by id: params[:id], token: params[:token]
  end
end
