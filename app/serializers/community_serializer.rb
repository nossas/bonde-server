class CommunitySerializer < ActiveModel::Serializer
  attributes :id, :name, :city, :mailchimp_api_key, :mailchimp_list_id, :mailchimp_group_id, :image, :description, :recipient, :facebook_app_id, :subscription_dead_days_interval, :subscription_retry_interval

  include PagarmeHelper

  def recipient
    if object.recipient
      return from_pagarme_recipient(object.recipient.recipient)
    end
    nil
  end
end
