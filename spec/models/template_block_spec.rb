require 'rails_helper'

RSpec.describe TemplateBlock, type: :model do
  it { should belong_to :template_mobilization }
  it { should have_many :template_widgets }
  it { should validate_presence_of :template_mobilization_id }
  it { should validate_presence_of :position }
  it { should accept_nested_attributes_for :template_widgets }
end
