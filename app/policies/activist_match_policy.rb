class ActivistMatchPolicy < ApplicationPolicy
  def permitted_attributes
    if create?
      [
        :match_id,
        :activist_id
      ]
    else
      []
    end
  end
end
