require 'rails_helper'

RSpec.describe ActivistFacebookBotInteraction, type: :model do
  it { should validate_presence_of :facebook_bot_configuration}
  it { should validate_presence_of :fb_context_recipient_id }
  it { should validate_presence_of :fb_context_sender_id }
  it { should validate_presence_of :interaction }
end
