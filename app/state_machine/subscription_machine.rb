class SubscriptionMachine
  include Statesman::Machine

  state :pending, initial: true
  state :paid
  state :unpaid
  state :canceled

  transition from: :pending, to: %i(paid unpaid canceled)
  transition from: :paid, to: %i(paid unpaid canceled)
  transition from: :unpaid, to: %i(paid unpaid canceled)

  after_transition(to: :paid) do |subscription|
    subscription.notify_activist(:paid_subscription)
    SubscriptionWorker.perform_at(
      subscription.next_transaction_charge_date,
      subscription.id)
  end

  after_transition(to: :unpaid) do |subscription|
    subscription.notify_activist(:unpaid_subscription)
  end

  after_transition(to: :canceled) do |subscription|
    subscription.notify_activist(:canceled_subscription)
  end
end
