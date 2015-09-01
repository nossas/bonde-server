class FormEntryPolicy < ApplicationPolicy
  def create?
    true
  end

  def permitted_attributes
    if create? || update?
      [:widget_id, :fields]
    else
      []
    end
  end
end
