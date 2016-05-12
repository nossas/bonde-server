class DonationPolicy < ApplicationPolicy
  def create?
    true
  end

  def permitted_attributes
    if create? || update?
      [:widget_id, :token, :payment_method, :amount, :email]
    else
      []
    end
  end

  private

  def is_owned_by?(user)
    user.present? && record.widget.mobilization.user == user
  end
end
