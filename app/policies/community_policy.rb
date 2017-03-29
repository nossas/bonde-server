class CommunityPolicy < ApplicationPolicy
  def permitted_attributes
    [:name, :city, :pagarme, :transfer_day, :transfer_enabled, :image, :description, :mailchimp_api_key, :mailchimp_list_id, :mailchimp_group_id, :fb_link, :twitter_link]
  end

  def can_handle_with_payables?
    is_owned_by?(user)
  end

  def can_handle_with_activist_actions?
    is_owned_by?(user)
  end

  def show?
    is_owned_by?(user)
  end

  def list_activists?
    is_owned_by?(user)
  end

  def add_activists?
    is_owned_by?(user)
  end

private

  def is_owned_by?(user)
    user.present? && record.users.include?(user)
  end
end
