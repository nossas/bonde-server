class UploadPolicy < ApplicationPolicy
  def index?
    user.present?
  end
end
