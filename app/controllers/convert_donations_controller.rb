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

    donation = widget.donations.joins(:activist).
                 where('activists.email = ? and subscription is null or not subscription', email).last

    if donation.present?
      new_donation = Donation.new(donation.attributes)
      new_donation.id = nil
      ew_donation.amount = amount if amount.present?
      new_donation.converted_from = donation.id
      new_donation.save

      return render json: new_donation
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  private

  def catch_widget
    Widget.find params[:widget_id]
  end
end
