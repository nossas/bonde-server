class BlockPolicy < ApplicationPolicy
  def permitted_attributes
    # if create?
      [:position, :bg_class, :bg_image, :hidden, :name, :menu_hidden,
        widgets_attributes: [:kind, :sm_size, :md_size, :lg_size]]
    # else
    #   []
    # end
  end

  def create?
    is_owned_by?(user)
  end

  def destroy?
    is_owned_by?(user)
  end

  private

  def is_owned_by?(user)
    user.present? && ( user.admin? or record.community.users.include? user or record.mobilization.user == user )
  end
end
