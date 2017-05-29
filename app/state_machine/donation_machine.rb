class DonationMachine
  include Statesman::Machine

  state :pending, initial: true
  state :waiting_payment
  state :processing
  state :paid
  state :refused
  state :chargeback
  state :pending_refund
  state :refunded

  transition from: :pending, to: %i(waiting_payment paid refused processing)
  transition from: :waiting_payment, to: %i(paid refused processing)
  transition from: :processing, to: %i(paid refused refunded pending_refund chargeback)
  transition from: :paid, to: %i(refunded chargeback pending_refund)
  transition from: :pending_refund, to: %i(refunded)

  after_transition from: :pending, to: :waiting_payment do |donation, transition| 
    donation.notify_when_not_subscription :waiting_payment_donation
  end

  after_transition from: :pending, to: :paid do |donation, transaction|
    donation.notify_when_not_subscription :paid_donation
  end

  after_transition from: :waiting_payment, to: :paid do |donation, transaction|
    donation.notify_when_not_subscription :paid_donation
  end

  after_transition to: :refused do |donation|
    donation.notify_when_not_subscription :refused_donation
  end

  after_transition do |donation, transition|
    donation.update_attributes transaction_status: transition.to_state
  end

  after_transition(to: :paid) do |donation|
    donation.async_update_mailchimp
  end

end
