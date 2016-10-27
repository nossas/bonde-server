require 'rails_helper'

RSpec.describe TemplateBlock, type: :model do
  it { should belong_to :template_mobilization }
  it { should validate_presence_of :template_mobilization_id }
  it { should validate_presence_of :position }
end
