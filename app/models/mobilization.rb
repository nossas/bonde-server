# -*- coding: utf-8 -*-
class Mobilization < ActiveRecord::Base
  include Shareable
  include Herokuable
  include Filterable

  validates :name, :user_id, :goal, :slug, presence: true
  validates :slug, uniqueness: true
  belongs_to :user
  belongs_to :community
  has_many :blocks
  has_many :widgets, through: :blocks
  has_many :form_entries, through: :widgets

  before_validation :slugify
  before_save :set_custom_domain
  before_save :set_color_scheme
  before_create :set_twitter_share_text

  def url
    if self.custom_domain.present?
      "http://#{self.custom_domain}"
    else
      "http://#{self.slug}.#{ENV["CLIENT_HOST"]}"
    end
  end

  def copy_from template
    self.color_scheme = template.color_scheme
    self.facebook_share_title = template.facebook_share_title
    self.facebook_share_description = template.facebook_share_description
    self.header_font = template.header_font
    self.body_font = template.body_font
    self.facebook_share_image = template.facebook_share_image
    self.slug = template.slug
    self.custom_domain = template.custom_domain
    self.twitter_share_text = template.twitter_share_text
    self
  end

  private

  def slugify
    self.slug ||= "#{self.class.count}-#{self.name.try(:parameterize)}"
  end

  def set_custom_domain
    return unless self.custom_domain_changed?
    delete_domain(self.custom_domain_was)
    create_domain({hostname: self.custom_domain})
  end

  def set_twitter_share_text
    self.twitter_share_text = "Acabei de colaborar com #{self.name}. Participe você também: "
  end

  def set_color_scheme
    if self.community.present?
      self.color_scheme = "#{self.community.name.delete(' ').parameterize}-scheme"
    end
  end

end
