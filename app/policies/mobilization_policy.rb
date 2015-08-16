class MobilizationPolicy < ApplicationPolicy
  def permitted_attributes
    if create? || update?
      [:name, :color_scheme, :google_analytics_code, :goal]
    else
      []
    end
  end
end
