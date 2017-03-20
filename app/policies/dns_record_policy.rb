class DnsRecordPolicy < ApplicationPolicy
  def permitted_attributes_for_create
    if community_user?
      [ :name, :record_type, :value, :ttl ]
    else
      []
    end
  end

  def permitted_attributes_for_update
    if community_user?
      [ :record_type, :value, :ttl ]
    else
      []
    end
  end

  def index?
    community_user?
  end

  def show?
    community_user?
  end

  def new?
    community_user?
  end

  def create?
    community_user?
  end

  def edit?
    community_user?
  end

  def update?
    community_user?
  end

  def destroy?
    community_user?
  end

  private

  def community_user?
    ( user ) && ( record.community ) && ( record.community.community_users.map(&:user).include? user )
  end
end