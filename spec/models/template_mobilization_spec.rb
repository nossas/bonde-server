require 'rails_helper'

RSpec.describe TemplateMobilization, type: :model do
  it { should belong_to :user }
  it { should have_many :template_blocks }
  it { should validate_presence_of :user_id }
  it { should validate_presence_of :name }
  it { should validate_length_of :twitter_share_text }

  before { @organization = Organization.make! }
end
