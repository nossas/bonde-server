class DonationPolicy < ApplicationPolicy
  def create?
    true
  end

  def permitted_attributes
    if create? || update?
      [:widget_id, :payment_method, :amount, :email, :card_hash]
    else
      []
    end
  end
end
