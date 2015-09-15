class MobilizationPolicy < ApplicationPolicy
  def permitted_attributes
    if create? || update?
      [
        :name,
        :color_scheme,
        :google_analytics_code,
        :goal,
        :facebook_share_title,
        :facebook_share_description,
        :facebook_share_image,
        :header_font,
        :body_font
      ]
    else
      []
    end
  end
end
