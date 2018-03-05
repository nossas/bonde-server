class SubscriptionsController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped
  respond_to :json

  def show
    when_have_subscription
  end

  def destroy
    when_have_subscription do
      unless subscription.canceled?
        subscription.transition_to(:canceled)
      end
    end
  end

  def recharge
    when_have_subscription do
      handle_update = subscription.handle_update(params)
      unless handle_update.errors.present?
        subscription.charge_next_payment if params[:card_hash].present? && subscription.unpaid?
      else
        return render json: handle_update.errors.to_json, status: 400
      end
    end
  end

  protected

  def subscription
    subscription ||= Subscription.find_by id: params[:id], token: params[:token]
  end

  def when_have_subscription
    if subscription.present?
      yield if block_given?
      render json: subscription, serializer: SubscriptionSerializer
    else
      render json: {}, status: '404'
    end
  end
end
