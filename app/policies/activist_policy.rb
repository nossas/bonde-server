class ActivistPolicy < ApplicationPolicy
  def permitted_attributes
    [:name, :email, :phone, :document_number, :document_type]
  end
end
