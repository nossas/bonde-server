class DonationPolicy < ApplicationPolicy
  def create?
    true
  end

  def permitted_attributes
    if create? || update?
      [:widget_id, :payment_method, :amount, :email, :card_hash, :customer]
    else
      []
    end
  end
end
