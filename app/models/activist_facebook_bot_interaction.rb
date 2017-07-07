class ActivistFacebookBotInteraction < ActiveRecord::Base
  belongs_to :activist
  belongs_to :facebook_bot_configuration

  validates :facebook_bot_configuation, :fb_context_recipient_id, :fb_context_sender_id, :interaction, presence: true
end
