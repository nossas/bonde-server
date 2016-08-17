class ActivistPressurePolicy < ApplicationPolicy
  def permitted_attributes
    [
      :widget_id,
      :activist_id,
      :firstname,
      :lastname,
      :mail
    ]
  end
end
