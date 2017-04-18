class SubscriptionSerializer < ActiveModel::Serializer
  attributes :id, :activist, :community, :last_donation, :current_state, :transitions, :amount, :next_transaction_charge_date, :status
end
