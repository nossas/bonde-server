class MobilizationPolicy < ApplicationPolicy
  def permitted_attributes
    if create? || update?
      [:name, :color_scheme, :google_analytics_code, :goal, :facebook_share_title, :facebook_share_description]
    else
      []
    end
  end
end
