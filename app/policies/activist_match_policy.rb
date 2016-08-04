class ActivistMatchPolicy < ApplicationPolicy
  def permitted_attributes
    [
      :match_id,
      :activist_id,
      :activist
    ]
  end
end
