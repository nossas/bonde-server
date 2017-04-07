class TemplateMobilization < ActiveRecord::Base
  include Shareable
  include Filterable

  validates :name, :user_id, :slug, presence: true
  belongs_to :user
  belongs_to :community

  has_many :template_blocks
  has_many :template_widgets, through: :template_blocks

  def self.create_from mobilization
  	template = TemplateMobilization.new
  	template.name = mobilization.name
  	template.color_scheme = mobilization.color_scheme
  	template.facebook_share_title = mobilization.facebook_share_title
  	template.facebook_share_description = mobilization.facebook_share_description
  	template.header_font = mobilization.header_font
  	template.body_font = mobilization.body_font
  	template.facebook_share_image = mobilization.facebook_share_image
  	template.slug = mobilization.slug
  	template.custom_domain = mobilization.custom_domain
  	template.twitter_share_text = mobilization.twitter_share_text
  	template.community_id = mobilization.community_id
  	template
  end

end
