require 'rails_helper'

RSpec.describe Widget, type: :model do
  it { should belong_to :block }
  it { should validate_presence_of :sm_size }
  it { should validate_presence_of :md_size }
  it { should validate_presence_of :lg_size }
  it { should validate_presence_of :kind }
end
