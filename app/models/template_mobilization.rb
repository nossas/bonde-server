class TemplateMobilization < ActiveRecord::Base
  include Shareable
  include Filterable

  validates :name, :user_id, presence: true
  belongs_to :user
  belongs_to :community

  has_many :template_blocks
  has_many :template_widgets, through: :template_blocks

  def self.create_from mobilization
    template = TemplateMobilization.new
    template.name = mobilization.name
    template.color_scheme = mobilization.color_scheme
    template.header_font = mobilization.header_font
    template.body_font = mobilization.body_font
    template.facebook_share_image = mobilization.facebook_share_image

    # TODO: discus about implementation of community context
    template.community_id = mobilization.community_id
    template
  end

end
