class BlockPolicy < ApplicationPolicy
  def permitted_attributes
    if create?
      [:position, :bg_class, :bg_image, :hidden, :name, :menu_hidden,
        widgets_attributes: [:kind, :sm_size, :md_size, :lg_size]]
    else
      []
    end
  end

  private

  def is_owned_by?(user)
    user.present? && record.mobilization.user == user
  end
end
