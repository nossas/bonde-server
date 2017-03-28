class SubscriptionSerializer < ActiveModel::Serializer
  attributes :id, :activist, :community, :last_donation
end
