class ActivistPolicy < ApplicationPolicy
  def permitted_attributes
    if create?
      [
        :name,
        :email,
        :phone,
        :document_number,
        :document_type
      ]
    else
      []
    end
  end
end
