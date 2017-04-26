class SubscriptionTransition < ActiveRecord::Base
  belongs_to :subscription, inverse_of: :transitions

  after_destroy :update_most_recent, if: :most_recent?

  private

  def update_most_recent
    last_transition = subscription.transitions.order(:sort_key).last
    return unless last_transition.present?
    last_transition.update_column(:most_recent, true)
  end
end
