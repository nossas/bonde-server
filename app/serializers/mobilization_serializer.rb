class MobilizationSerializer < ActiveModel::Serializer
  attributes :id, :name, :created_at, :updated_at, :user_id, :color_scheme, :google_analytics_code, :goal,
             :header_font, :body_font, :facebook_share_title, :facebook_share_description, :facebook_share_image, :slug,
             :custom_domain, :twitter_share_text, :community_id, :tag_list, :favicon, :status, :language
end
