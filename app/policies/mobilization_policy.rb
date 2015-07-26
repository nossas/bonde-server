class MobilizationPolicy < ApplicationPolicy
  def permitted_attributes
    if create?
      [:name, :color_scheme]
    else
      []
    end
  end
end
