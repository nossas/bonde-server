class DonationPolicy < ApplicationPolicy
  def create?
    true
  end

  def permitted_attributes
    if create? || update?
      [:widget_id,
       :subscription,
       :period,
       :payment_method,
       :amount,
       :email,
       :card_hash,
       customer: [
        :name,
        :email,
        :document_number,
        phone: [
          :ddd,
          :number
        ],
        address: [
          :zipcode,
          :street,
          :street_number,
          :complementary,
          :neighborhood,
          :city,
          :state
        ]
      ]]
    else
      []
    end
  end

  private

  def is_owned_by?(user)
    user.present? && record.widget.mobilization.user == user
  end
end
