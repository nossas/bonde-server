require 'rails_helper'

RSpec.describe TemplateWidget, type: :model do
  it { should belong_to :template_block }
  it { should validate_presence_of :sm_size }
  it { should validate_presence_of :md_size }
  it { should validate_presence_of :lg_size }
  it { should validate_presence_of :kind }
  it { should validate_uniqueness_of :mailchimp_segment_id }
end
