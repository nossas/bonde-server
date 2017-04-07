class AddressPolicy < ApplicationPolicy
  def permitted_attributes
    [:zipcode, :street, :street_number, :complementary, :neighborhood, :city, :state]
  end
end


  